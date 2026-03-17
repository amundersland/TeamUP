-- ============================================================
-- TeamUP Database — Seed Data
-- PostgreSQL
--
-- Inserts realistic test data:
--   10 employees (alternating F/M, all 4-letter names)
--   4 learning paths
--   40 learning materials (10 books, 10 online courses,
--                          10 YouTube videos, 10 live courses)
--   15 tags, 6 wiki notes, 4 employee groups
--   All binding rows wiring everything together
--
-- Run after schema.sql:
--   psql -U <user> -d <db> -f db-schema/schema.sql
--   psql -U <user> -d <db> -f db-schema/seed.sql
-- ============================================================

SET search_path TO teamup;

-- ============================================================
-- LOOKUP TABLES
-- ============================================================

INSERT INTO learning_material_type (name) VALUES
    ('Book'),
    ('Online Course'),
    ('YouTube'),
    ('Live Course');

INSERT INTO learning_path_type (name) VALUES
    ('Certification'),
    ('Onboarding'),
    ('Skill Path'),
    ('Team Track');

-- ============================================================
-- TAGS
-- ============================================================

INSERT INTO tag (name, description) VALUES
    ('Backend',     'Server-side development'),
    ('Frontend',    'Client-side development'),
    ('DevOps',      'Development operations and automation'),
    ('Cloud',       'Cloud platforms and infrastructure'),
    ('Data',        'Data engineering and science'),
    ('Python',      'Python programming language'),
    ('Java',        'Java and JVM ecosystem'),
    ('JavaScript',  'JavaScript and Node.js'),
    ('Docker',      'Containerisation with Docker'),
    ('Kubernetes',  'Container orchestration with K8s'),
    ('Git',         'Version control with Git'),
    ('Agile',       'Agile methodologies and Scrum'),
    ('Security',    'Application and infrastructure security'),
    ('TypeScript',  'TypeScript language and tooling'),
    ('SQL',         'Relational databases and SQL');

-- ============================================================
-- WIKI NOTES
-- ============================================================

INSERT INTO wiki_note (title, body) VALUES
    ('Getting Started',
     'Welcome to TeamUP. Start here for onboarding steps, tool access, and account setup.'),
    ('Team Conventions',
     'Coding standards, branch naming, commit message format, and PR review rules.'),
    ('Learning Budget Policy',
     'Each employee has a NOK 5 000/year learning budget. Submit receipts to HR within 30 days.'),
    ('Cloud Platform Guide',
     'Internal guide to Azure subscriptions, naming conventions, resource tagging, and cost centres.'),
    ('DevOps Runbook',
     'CI/CD pipeline overview, deployment checklist, secrets management, and rollback procedures.'),
    ('Frontend Standards',
     'Agreed component library, accessibility guidelines, design token usage, and browser support matrix.');

-- ============================================================
-- EMPLOYEES  (F, M, F, M, F, M, F, M, F, M — all 4-letter names)
-- ============================================================

INSERT INTO employee (fullname, job_title, age) VALUES
    ('Anne', 'Frontend Dev',    28),
    ('Bent', 'Backend Dev',     34),
    ('Cara', 'UX Designer',     26),
    ('Dani', 'DevOps Engineer', 31),
    ('Elsa', 'Data Scientist',  29),
    ('Finn', 'Team Lead',       38),
    ('Gwen', 'QA Engineer',     27),
    ('Hugo', 'Cloud Architect', 42),
    ('Iris', 'Product Owner',   33),
    ('Joel', 'Full-Stack Dev',  30);

-- ============================================================
-- EMPLOYEE GROUPS
-- ============================================================

INSERT INTO employee_group (groupname, purpose, tag_ids, wiki_note_ids) VALUES
    ('Backend Team',
     'Backend development',
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java'),
           (SELECT id FROM tag WHERE name = 'SQL')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Team Conventions')]),

    ('Frontend Team',
     'Frontend development',
     ARRAY[(SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript'),
           (SELECT id FROM tag WHERE name = 'TypeScript')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Frontend Standards'),
           (SELECT id FROM wiki_note WHERE title = 'Team Conventions')]),

    ('DevOps Team',
     'Infrastructure & ops',
     ARRAY[(SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Cloud'),
           (SELECT id FROM tag WHERE name = 'Docker'),
           (SELECT id FROM tag WHERE name = 'Kubernetes')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'DevOps Runbook'),
           (SELECT id FROM wiki_note WHERE title = 'Cloud Platform Guide')]),

    ('Leadership',
     'Team leads and POs',
     ARRAY[(SELECT id FROM tag WHERE name = 'Agile')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Learning Budget Policy'),
           (SELECT id FROM wiki_note WHERE title = 'Team Conventions')]);

-- ============================================================
-- LEARNING PATHS
-- (name is VARCHAR(20) — keep short)
-- ============================================================

INSERT INTO learning_path (name, type_id, tag_ids, wiki_note_ids) VALUES
    ('Cloud & DevOps',
     (SELECT id FROM learning_path_type WHERE name = 'Certification'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Cloud'),
           (SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Docker'),
           (SELECT id FROM tag WHERE name = 'Kubernetes')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Cloud Platform Guide'),
           (SELECT id FROM wiki_note WHERE title = 'DevOps Runbook')]),

    ('Frontend Track',
     (SELECT id FROM learning_path_type WHERE name = 'Skill Path'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript'),
           (SELECT id FROM tag WHERE name = 'TypeScript')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Frontend Standards')]),

    ('Backend Track',
     (SELECT id FROM learning_path_type WHERE name = 'Skill Path'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java'),
           (SELECT id FROM tag WHERE name = 'SQL')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Team Conventions')]),

    ('New Hire Path',
     (SELECT id FROM learning_path_type WHERE name = 'Onboarding'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Git'),
           (SELECT id FROM tag WHERE name = 'Agile')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Getting Started'),
           (SELECT id FROM wiki_note WHERE title = 'Team Conventions'),
           (SELECT id FROM wiki_note WHERE title = 'Learning Budget Policy')]);

-- ============================================================
-- LEARNING MATERIALS
-- ============================================================

-- ── 10 Books ─────────────────────────────────────────────────

INSERT INTO learning_material (name, description, link, price, type_id, tag_ids, wiki_note_ids) VALUES
    ('Clean Code',
     'Timeless principles for writing readable and maintainable code.',
     'https://www.oreilly.com/library/view/clean-code/9780136083238/',
     399,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Team Conventions')]),

    ('The Pragmatic Programmer',
     'Practical advice for developers: from journeyman to master.',
     'https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/',
     429,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Git')],
     '{}'),

    ('Designing Data-Intensive Apps',
     'Deep dive into distributed systems, storage engines, and data pipelines.',
     'https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/',
     499,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Data'),
           (SELECT id FROM tag WHERE name = 'SQL'),
           (SELECT id FROM tag WHERE name = 'Backend')],
     '{}'),

    ('Docker Deep Dive',
     'Concise and practical introduction to Docker concepts and workflows.',
     'https://www.amazon.com/Docker-Deep-Dive-Nigel-Poulton/dp/1521822807',
     249,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Docker'),
           (SELECT id FROM tag WHERE name = 'DevOps')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'DevOps Runbook')]),

    ('Python Crash Course',
     'Fast-paced, hands-on introduction to Python for beginners.',
     'https://nostarch.com/python-crash-course-3rd-edition',
     349,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Python'),
           (SELECT id FROM tag WHERE name = 'Backend')],
     '{}'),

    ('You Don''t Know JS',
     'In-depth exploration of JavaScript''s core mechanisms. Free on GitHub.',
     'https://github.com/getify/You-Dont-Know-JS',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'JavaScript'),
           (SELECT id FROM tag WHERE name = 'Frontend')],
     '{}'),

    ('Kubernetes in Action',
     'Comprehensive guide to deploying and managing applications on Kubernetes.',
     'https://www.manning.com/books/kubernetes-in-action',
     499,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Kubernetes'),
           (SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Cloud')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'Cloud Platform Guide'),
           (SELECT id FROM wiki_note WHERE title = 'DevOps Runbook')]),

    ('Clean Architecture',
     'Principles and patterns for building sustainable software architecture.',
     'https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/',
     399,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java')],
     '{}'),

    ('The DevOps Handbook',
     'How to create world-class agility, reliability, and security in technology organisations.',
     'https://itrevolution.com/product/the-devops-handbook/',
     449,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Agile')],
     ARRAY[(SELECT id FROM wiki_note WHERE title = 'DevOps Runbook')]),

    ('SQL Performance Explained',
     'Everything developers need to know about SQL performance and indexing.',
     'https://use-the-index-luke.com/sql/table-of-contents',
     299,
     (SELECT id FROM learning_material_type WHERE name = 'Book'),
     ARRAY[(SELECT id FROM tag WHERE name = 'SQL'),
           (SELECT id FROM tag WHERE name = 'Backend')],
     '{}');

-- ── 10 Online Courses ─────────────────────────────────────────

INSERT INTO learning_material (name, description, link, price, type_id, tag_ids) VALUES
    ('AWS Solutions Architect',
     'Comprehensive preparation course for the AWS SAA-C03 certification exam.',
     'https://www.udemy.com/course/aws-certified-solutions-architect-associate-saa-c03/',
     149,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Cloud'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('React - The Complete Guide',
     'Learn React from scratch including hooks, Redux, and Next.js.',
     'https://www.udemy.com/course/react-the-complete-guide-incl-redux/',
     149,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript'),
           (SELECT id FROM tag WHERE name = 'TypeScript')]),

    ('Docker & Kubernetes',
     'Practical guide to building and deploying containerised applications.',
     'https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/',
     149,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Docker'),
           (SELECT id FROM tag WHERE name = 'Kubernetes'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('Python for Data Science',
     'Learn NumPy, Pandas, Matplotlib, Seaborn, and ML with Python.',
     'https://www.udemy.com/course/python-for-data-science-and-machine-learning-bootcamp/',
     149,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Python'),
           (SELECT id FROM tag WHERE name = 'Data')]),

    ('Spring Boot Masterclass',
     'Build production-ready REST APIs with Spring Boot and Spring Security.',
     'https://www.udemy.com/course/spring-boot-tutorial-for-beginners/',
     129,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java')]),

    ('TypeScript Essential Training',
     'TypeScript fundamentals and advanced typing for JavaScript developers.',
     'https://www.linkedin.com/learning/typescript-essential-training-14687057',
     49,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'TypeScript'),
           (SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript')]),

    ('Git & GitHub Bootcamp',
     'Master Git branching, merging, rebasing, and GitHub collaboration workflows.',
     'https://www.udemy.com/course/git-and-github-bootcamp/',
     99,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Git'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('Agile with Scrum',
     'Scrum framework from theory to practice, including sprint ceremonies and artifacts.',
     'https://www.coursera.org/learn/agile-development-and-scrum',
     79,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Agile')]),

    ('Node.js - The Complete Guide',
     'Build fast and scalable server-side applications with Node.js and Express.',
     'https://www.udemy.com/course/nodejs-the-complete-guide/',
     149,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'JavaScript')]),

    ('PostgreSQL for Beginners',
     'Relational database design, SQL queries, and PostgreSQL-specific features.',
     'https://www.udemy.com/course/postgresql-for-beginners-and-everyone/',
     99,
     (SELECT id FROM learning_material_type WHERE name = 'Online Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'SQL'),
           (SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Data')]);

-- ── 10 YouTube Videos ────────────────────────────────────────

INSERT INTO learning_material (name, description, link, price, type_id, tag_ids) VALUES
    ('Docker in 100 Seconds',
     'Fireship: Concise animated overview of Docker concepts and workflow.',
     'https://www.youtube.com/watch?v=Gjnup-PuquQ',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Docker'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('React Crash Course',
     'Traversy Media: Build a complete React app from scratch in a single session.',
     'https://www.youtube.com/watch?v=w7ejDZ8SWv8',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript')]),

    ('Kubernetes Tutorial',
     'TechWorld with Nana: Full Kubernetes course for beginners (4+ hours).',
     'https://www.youtube.com/watch?v=X48VuDVv0do',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Kubernetes'),
           (SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Cloud')]),

    ('TypeScript in 100 Seconds',
     'Fireship: Lightning-fast TypeScript overview for JavaScript developers.',
     'https://www.youtube.com/watch?v=zQnBQ4tB3ZA',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'TypeScript'),
           (SELECT id FROM tag WHERE name = 'JavaScript')]),

    ('Git for Professionals',
     'Tobias Günther: Advanced Git techniques — rebase, cherry-pick, reflog.',
     'https://www.youtube.com/watch?v=Uszj_k0DGsg',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Git'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('Linux Basics for Hackers',
     'NetworkChuck: Essential Linux command-line skills for developers and ops.',
     'https://www.youtube.com/watch?v=VbEx7B_PTOE',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Security')]),

    ('REST API Design',
     'Web Dev Simplified: Best practices for designing clean RESTful APIs.',
     'https://www.youtube.com/watch?v=-MTSQjw5DrM',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'JavaScript')]),

    ('Database Indexing Explained',
     'Hussein Nasser: How database indexes work under the hood.',
     'https://www.youtube.com/watch?v=-qNSXK7s7_w',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'SQL'),
           (SELECT id FROM tag WHERE name = 'Backend')]),

    ('CI/CD Pipeline with GitHub',
     'TechWorld with Nana: Set up a complete CI/CD pipeline from scratch.',
     'https://www.youtube.com/watch?v=R8_veQiYBjI',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Git')]),

    ('Python in 100 Seconds',
     'Fireship: Brief but complete intro to Python for seasoned developers.',
     'https://www.youtube.com/watch?v=x7X9w_GIm1s',
     0,
     (SELECT id FROM learning_material_type WHERE name = 'YouTube'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Python'),
           (SELECT id FROM tag WHERE name = 'Backend')]);

-- ── 10 Live Courses ───────────────────────────────────────────

INSERT INTO learning_material (name, description, link, price, type_id, tag_ids) VALUES
    ('AWS Cloud Practitioner Boot',
     '2-day intensive bootcamp covering the AWS Cloud Practitioner exam syllabus.',
     'https://aws.amazon.com/training/classroom/aws-cloud-practitioner-essentials/',
     1990,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Cloud'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('Scrum Master Certification',
     '2-day PSM I preparation and exam. Includes workbook and coaching session.',
     'https://www.scrum.org/courses/professional-scrum-master-training',
     2490,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Agile')]),

    ('Kubernetes CKA Bootcamp',
     '3-day Certified Kubernetes Administrator exam-prep live course.',
     'https://training.linuxfoundation.org/training/kubernetes-administration/',
     3990,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Kubernetes'),
           (SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Cloud')]),

    ('OWASP Security Workshop',
     '1-day hands-on workshop covering the OWASP Top 10 and secure coding practices.',
     'https://owasp.org/www-project-training/',
     1490,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Security'),
           (SELECT id FROM tag WHERE name = 'Backend')]),

    ('Data Engineering Workshop',
     '2-day workshop on modern data pipelines, dbt, Airflow, and data warehousing.',
     'https://www.dataengineeringcamp.com/',
     2990,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Data'),
           (SELECT id FROM tag WHERE name = 'Python'),
           (SELECT id FROM tag WHERE name = 'SQL')]),

    ('React Advanced Patterns',
     '1-day advanced workshop on React design patterns, performance, and testing.',
     'https://www.frontendmasters.com/workshops/',
     1990,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Frontend'),
           (SELECT id FROM tag WHERE name = 'JavaScript'),
           (SELECT id FROM tag WHERE name = 'TypeScript')]),

    ('Spring Boot in 2 Days',
     'Instructor-led course covering REST, JPA, Flyway, security, and testing.',
     'https://www.pluralsight.com/courses/spring-boot-fundamentals',
     2490,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'Java')]),

    ('PostgreSQL Admin Workshop',
     '1-day workshop on PostgreSQL administration, query tuning, and backup.',
     'https://www.enterprisedb.com/training/postgresql-dba-training',
     1790,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'SQL'),
           (SELECT id FROM tag WHERE name = 'Backend'),
           (SELECT id FROM tag WHERE name = 'DevOps')]),

    ('Python ML Fundamentals',
     '2-day live course on machine learning foundations using Python and scikit-learn.',
     'https://www.coursera.org/instructor-led',
     2990,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'Python'),
           (SELECT id FROM tag WHERE name = 'Data')]),

    ('DevOps on Azure',
     '2-day Azure DevOps course covering pipelines, repos, artifacts, and test plans.',
     'https://learn.microsoft.com/en-us/training/courses/az-400t00',
     2490,
     (SELECT id FROM learning_material_type WHERE name = 'Live Course'),
     ARRAY[(SELECT id FROM tag WHERE name = 'DevOps'),
           (SELECT id FROM tag WHERE name = 'Cloud'),
           (SELECT id FROM tag WHERE name = 'Git')]);

-- ============================================================
-- BINDINGS: learning paths ↔ learning materials
-- ============================================================

INSERT INTO learning_path_has_learning_material (learning_path_id, learning_material_id)
SELECT lp.id, lm.id FROM learning_path lp, learning_material lm
WHERE lp.name = 'Cloud & DevOps'
  AND lm.name IN (
    'Docker Deep Dive', 'Kubernetes in Action', 'The DevOps Handbook',
    'AWS Solutions Architect', 'Docker & Kubernetes', 'Git & GitHub Bootcamp',
    'Docker in 100 Seconds', 'Kubernetes Tutorial', 'CI/CD Pipeline with GitHub',
    'AWS Cloud Practitioner Boot', 'Kubernetes CKA Bootcamp', 'DevOps on Azure');

INSERT INTO learning_path_has_learning_material (learning_path_id, learning_material_id)
SELECT lp.id, lm.id FROM learning_path lp, learning_material lm
WHERE lp.name = 'Frontend Track'
  AND lm.name IN (
    'You Don''t Know JS', 'React - The Complete Guide', 'TypeScript Essential Training',
    'React Crash Course', 'TypeScript in 100 Seconds', 'REST API Design',
    'React Advanced Patterns');

INSERT INTO learning_path_has_learning_material (learning_path_id, learning_material_id)
SELECT lp.id, lm.id FROM learning_path lp, learning_material lm
WHERE lp.name = 'Backend Track'
  AND lm.name IN (
    'Clean Code', 'Clean Architecture', 'SQL Performance Explained',
    'Spring Boot Masterclass', 'Node.js - The Complete Guide', 'PostgreSQL for Beginners',
    'Database Indexing Explained', 'REST API Design', 'OWASP Security Workshop',
    'Spring Boot in 2 Days', 'PostgreSQL Admin Workshop');

INSERT INTO learning_path_has_learning_material (learning_path_id, learning_material_id)
SELECT lp.id, lm.id FROM learning_path lp, learning_material lm
WHERE lp.name = 'New Hire Path'
  AND lm.name IN (
    'The Pragmatic Programmer', 'Git & GitHub Bootcamp', 'Agile with Scrum',
    'Git for Professionals', 'Scrum Master Certification');

-- ============================================================
-- BINDINGS: employees ↔ learning paths
-- ============================================================

INSERT INTO employee_has_learning_path (employee_id, learning_path_id)
SELECT e.id, lp.id FROM employee e, learning_path lp
WHERE (e.fullname = 'Anne' AND lp.name IN ('Frontend Track', 'New Hire Path'))
   OR (e.fullname = 'Bent' AND lp.name IN ('Backend Track',  'New Hire Path'))
   OR (e.fullname = 'Cara' AND lp.name IN ('Frontend Track', 'New Hire Path'))
   OR (e.fullname = 'Dani' AND lp.name IN ('Cloud & DevOps', 'New Hire Path'))
   OR (e.fullname = 'Elsa' AND lp.name IN ('Backend Track',  'New Hire Path'))
   OR (e.fullname = 'Finn' AND lp.name =  'New Hire Path')
   OR (e.fullname = 'Gwen' AND lp.name IN ('Backend Track',  'New Hire Path'))
   OR (e.fullname = 'Hugo' AND lp.name =  'Cloud & DevOps')
   OR (e.fullname = 'Iris' AND lp.name =  'New Hire Path')
   OR (e.fullname = 'Joel' AND lp.name IN ('Frontend Track', 'Backend Track', 'New Hire Path'));

-- ============================================================
-- BINDINGS: employees ↔ learning materials (individual picks)
-- ============================================================

INSERT INTO employee_has_learning_material (employee_id, learning_material_id)
SELECT e.id, lm.id FROM employee e, learning_material lm
WHERE (e.fullname = 'Anne' AND lm.name IN (
    'React - The Complete Guide', 'TypeScript Essential Training',
    'React Crash Course', 'You Don''t Know JS'))
   OR (e.fullname = 'Bent' AND lm.name IN (
    'Clean Code', 'Spring Boot Masterclass',
    'SQL Performance Explained', 'Clean Architecture'))
   OR (e.fullname = 'Cara' AND lm.name IN (
    'React - The Complete Guide', 'REST API Design', 'React Advanced Patterns'))
   OR (e.fullname = 'Dani' AND lm.name IN (
    'Docker Deep Dive', 'Docker & Kubernetes',
    'Kubernetes in Action', 'DevOps on Azure'))
   OR (e.fullname = 'Elsa' AND lm.name IN (
    'Python for Data Science', 'Designing Data-Intensive Apps',
    'Data Engineering Workshop', 'Python Crash Course'))
   OR (e.fullname = 'Finn' AND lm.name IN (
    'The Pragmatic Programmer', 'Agile with Scrum',
    'Scrum Master Certification', 'The DevOps Handbook'))
   OR (e.fullname = 'Gwen' AND lm.name IN (
    'PostgreSQL for Beginners', 'OWASP Security Workshop', 'Database Indexing Explained'))
   OR (e.fullname = 'Hugo' AND lm.name IN (
    'Kubernetes in Action', 'AWS Solutions Architect',
    'AWS Cloud Practitioner Boot', 'Kubernetes CKA Bootcamp'))
   OR (e.fullname = 'Iris' AND lm.name IN (
    'Agile with Scrum', 'Scrum Master Certification', 'The Pragmatic Programmer'))
   OR (e.fullname = 'Joel' AND lm.name IN (
    'Node.js - The Complete Guide', 'TypeScript Essential Training',
    'PostgreSQL for Beginners', 'Spring Boot Masterclass'));

-- ============================================================
-- BINDINGS: employee groups ↔ employees
-- ============================================================

INSERT INTO employee_group_has_employee (employee_group_id, employee_id)
SELECT eg.id, e.id FROM employee_group eg, employee e
WHERE (eg.groupname = 'Backend Team'  AND e.fullname IN ('Bent', 'Elsa', 'Gwen', 'Joel'))
   OR (eg.groupname = 'Frontend Team' AND e.fullname IN ('Anne', 'Cara', 'Joel'))
   OR (eg.groupname = 'DevOps Team'   AND e.fullname IN ('Dani', 'Hugo'))
   OR (eg.groupname = 'Leadership'    AND e.fullname IN ('Finn', 'Iris'));

-- ============================================================
-- BINDINGS: employee groups ↔ learning paths
-- ============================================================

INSERT INTO employee_group_has_learning_path (employee_group_id, learning_path_id)
SELECT eg.id, lp.id FROM employee_group eg, learning_path lp
WHERE (eg.groupname = 'Backend Team'  AND lp.name = 'Backend Track')
   OR (eg.groupname = 'Frontend Team' AND lp.name = 'Frontend Track')
   OR (eg.groupname = 'DevOps Team'   AND lp.name = 'Cloud & DevOps')
   OR (eg.groupname = 'Leadership'    AND lp.name = 'New Hire Path');

-- ============================================================
-- BINDINGS: employee groups ↔ learning materials
-- ============================================================

INSERT INTO employee_group_has_learning_material (employee_group_id, learning_material_id)
SELECT eg.id, lm.id FROM employee_group eg, learning_material lm
WHERE (eg.groupname = 'Backend Team' AND lm.name IN (
    'Clean Code', 'Clean Architecture', 'SQL Performance Explained',
    'Spring Boot Masterclass', 'OWASP Security Workshop', 'Spring Boot in 2 Days'))
   OR (eg.groupname = 'Frontend Team' AND lm.name IN (
    'You Don''t Know JS', 'React - The Complete Guide',
    'TypeScript Essential Training', 'React Advanced Patterns'))
   OR (eg.groupname = 'DevOps Team' AND lm.name IN (
    'Docker Deep Dive', 'Kubernetes in Action', 'The DevOps Handbook',
    'Docker & Kubernetes', 'AWS Cloud Practitioner Boot',
    'Kubernetes CKA Bootcamp', 'DevOps on Azure'))
   OR (eg.groupname = 'Leadership' AND lm.name IN (
    'The Pragmatic Programmer', 'Agile with Scrum', 'Scrum Master Certification'));