#!/usr/bin/env python3
"""
Simple CLI tool for TeamUP database operations

Usage:
    python cli.py employee list
    python cli.py employee create "John Doe" --job-title "Developer" --age 30
    python cli.py employee delete 1
    python cli.py type list
    python cli.py type create "Book"
    python cli.py material list
    python cli.py material create "Python Guide" --type "Book" --price 2500
"""
import argparse
import sys
import logging
from teamup.database import get_session
from teamup.repository import EmployeeRepository, LearningMaterialTypeRepository, LearningMaterialRepository
from teamup.models import Employee, LearningMaterialType, LearningMaterial

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)


def list_employees(args):
    """List all employees"""
    with get_session() as session:
        repo = EmployeeRepository(session)
        employees = repo.get_all()
        
        if not employees:
            logger.info("No employees found")
            return
        
        logger.info(f"Found {len(employees)} employee(s):\n")
        for emp in employees:
            job = f", Job: {emp.job_title}" if emp.job_title else ""
            age = f", Age: {emp.age}" if emp.age else ""
            logger.info(f"  [{emp.id}] {emp.fullname}{job}{age}")


def create_employee(args):
    """Create a new employee"""
    with get_session() as session:
        repo = EmployeeRepository(session)
        employee = repo.create(
            fullname=args.name,
            job_title=args.job_title,
            age=args.age
        )
        logger.info(f"Created employee: [{employee.id}] {employee.fullname}")


def delete_employee(args):
    """Delete an employee by ID"""
    with get_session() as session:
        repo = EmployeeRepository(session)
        if repo.delete(args.id):
            logger.info(f"Deleted employee with ID {args.id}")
        else:
            logger.error(f"Employee with ID {args.id} not found")
            sys.exit(1)


def list_types(args):
    """List all learning material types"""
    with get_session() as session:
        repo = LearningMaterialTypeRepository(session)
        types = repo.get_all()
        
        if not types:
            logger.info("No learning material types found")
            return
        
        logger.info(f"Found {len(types)} type(s):\n")
        for t in types:
            logger.info(f"  [{t.id}] {t.name}")


def create_type(args):
    """Create a new learning material type"""
    with get_session() as session:
        repo = LearningMaterialTypeRepository(session)
        try:
            type_obj = repo.create(name=args.name)
            logger.info(f"Created type: [{type_obj.id}] {type_obj.name}")
        except Exception as e:
            logger.error(f"Failed to create type: {e}")
            sys.exit(1)


def list_materials(args):
    """List all learning materials"""
    with get_session() as session:
        repo = LearningMaterialRepository(session)
        materials = repo.get_all()
        
        if not materials:
            logger.info("No learning materials found")
            return
        
        logger.info(f"Found {len(materials)} material(s):\n")
        for mat in materials:
            type_name = mat.type.name if mat.type else "Unknown"
            price = f", Price: {mat.price} kr" if mat.price else ""
            logger.info(f"  [{mat.id}] {mat.name} (Type: {type_name}{price})")


def create_material(args):
    """Create a new learning material"""
    with get_session() as session:
        # First, find the type by name
        type_repo = LearningMaterialTypeRepository(session)
        type_obj = type_repo.get_by_name(args.type)
        
        if not type_obj:
            logger.error(f"Learning material type '{args.type}' not found")
            logger.info("Available types:")
            for t in type_repo.get_all():
                logger.info(f"  - {t.name}")
            sys.exit(1)
        
        # Create the material
        repo = LearningMaterialRepository(session)
        material = repo.create(
            name=args.name,
            description=args.description,
            link=args.link,
            price=args.price,
            type_id=type_obj.id
        )
        logger.info(f"Created material: [{material.id}] {material.name}")


def main():
    parser = argparse.ArgumentParser(
        description="TeamUP Database CLI Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    subparsers = parser.add_subparsers(dest='entity', help='Entity type')
    
    # Employee commands
    employee_parser = subparsers.add_parser('employee', help='Employee operations')
    employee_subparsers = employee_parser.add_subparsers(dest='action', help='Action')
    
    employee_list = employee_subparsers.add_parser('list', help='List all employees')
    employee_list.set_defaults(func=list_employees)
    
    employee_create = employee_subparsers.add_parser('create', help='Create a new employee')
    employee_create.add_argument('name', help='Full name of the employee')
    employee_create.add_argument('--job-title', help='Job title')
    employee_create.add_argument('--age', type=int, help='Age')
    employee_create.set_defaults(func=create_employee)
    
    employee_delete = employee_subparsers.add_parser('delete', help='Delete an employee')
    employee_delete.add_argument('id', type=int, help='Employee ID')
    employee_delete.set_defaults(func=delete_employee)
    
    # Type commands
    type_parser = subparsers.add_parser('type', help='Learning material type operations')
    type_subparsers = type_parser.add_subparsers(dest='action', help='Action')
    
    type_list = type_subparsers.add_parser('list', help='List all types')
    type_list.set_defaults(func=list_types)
    
    type_create = type_subparsers.add_parser('create', help='Create a new type')
    type_create.add_argument('name', help='Type name')
    type_create.set_defaults(func=create_type)
    
    # Material commands
    material_parser = subparsers.add_parser('material', help='Learning material operations')
    material_subparsers = material_parser.add_subparsers(dest='action', help='Action')
    
    material_list = material_subparsers.add_parser('list', help='List all materials')
    material_list.set_defaults(func=list_materials)
    
    material_create = material_subparsers.add_parser('create', help='Create a new material')
    material_create.add_argument('name', help='Material name')
    material_create.add_argument('--type', required=True, help='Type name')
    material_create.add_argument('--description', help='Description')
    material_create.add_argument('--link', help='Link URL')
    material_create.add_argument('--price', type=int, help='Price in NOK')
    material_create.set_defaults(func=create_material)
    
    # Parse arguments
    args = parser.parse_args()
    
    if not hasattr(args, 'func'):
        parser.print_help()
        sys.exit(1)
    
    # Execute the command
    try:
        args.func(args)
    except KeyboardInterrupt:
        logger.info("\nAborted")
        sys.exit(130)
    except Exception as e:
        logger.error(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
