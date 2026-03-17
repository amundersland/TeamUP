package no.teamup.core.model

import org.hibernate.HibernateException
import org.hibernate.engine.spi.SharedSessionContractImplementor
import org.hibernate.usertype.UserType
import java.io.Serializable
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.SQLException
import java.sql.Types

/**
 * Custom Hibernate UserType for mapping PostgreSQL INTEGER[] arrays to IntArray in Kotlin.
 * This handles the conversion between PostgreSQL's native array type and Java/Kotlin arrays.
 */
class PostgreSQLIntArrayType : UserType<IntArray> {

    override fun getSqlType(): Int = Types.ARRAY

    override fun returnedClass(): Class<IntArray> = IntArray::class.java

    override fun equals(x: IntArray?, y: IntArray?): Boolean {
        return x.contentEquals(y)
    }

    override fun hashCode(x: IntArray?): Int {
        return x?.contentHashCode() ?: 0
    }

    @Throws(HibernateException::class, SQLException::class)
    override fun nullSafeGet(
        rs: ResultSet,
        position: Int,
        session: SharedSessionContractImplementor?,
        owner: Any?
    ): IntArray? {
        val array = rs.getArray(position) ?: return null
        
        return try {
            val arrayData = array.array as? Array<*>
            arrayData?.mapNotNull { 
                when (it) {
                    is Int -> it
                    is Number -> it.toInt()
                    else -> null
                }
            }?.toIntArray()
        } finally {
            array.free()
        }
    }

    @Throws(HibernateException::class, SQLException::class)
    override fun nullSafeSet(
        st: PreparedStatement,
        value: IntArray?,
        index: Int,
        session: SharedSessionContractImplementor?
    ) {
        if (value == null) {
            st.setNull(index, Types.ARRAY)
        } else {
            val connection = st.connection
            val array = connection.createArrayOf("integer", value.toTypedArray())
            st.setArray(index, array)
        }
    }

    override fun deepCopy(value: IntArray?): IntArray? {
        return value?.copyOf()
    }

    override fun isMutable(): Boolean = true

    override fun disassemble(value: IntArray?): Serializable? {
        return deepCopy(value)
    }

    override fun assemble(cached: Serializable?, owner: Any?): IntArray? {
        return deepCopy(cached as? IntArray)
    }
}
