-- ============================================================
-- TeamUP Database Schema
-- PostgreSQL
-- ============================================================

DROP SCHEMA IF EXISTS teamup CASCADE;
CREATE SCHEMA teamup;
SET search_path TO teamup;

-- ============================================================
-- LOOKUP / TYPE TABLES
-- ============================================================

CREATE TABLE tag (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    CONSTRAINT uq_tag_name  UNIQUE (name),
    CONSTRAINT chk_tag_name CHECK (TRIM(name) <> '')
);

CREATE TABLE wiki_note (
    id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    body  TEXT,
    CONSTRAINT chk_wiki_note_title CHECK (TRIM(title) <> '')
);

CREATE TABLE learning_material_type (
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    CONSTRAINT uq_lmt_name  UNIQUE (name),
    CONSTRAINT chk_lmt_name CHECK (TRIM(name) <> '')
);

CREATE TABLE learning_path_type (
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_lpt_name  UNIQUE (name),
    CONSTRAINT chk_lpt_name CHECK (TRIM(name) <> '')
);

-- ============================================================
-- ENTITY TABLES
-- ============================================================

CREATE TABLE employee (
    id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fullname  VARCHAR(50) NOT NULL,
    job_title VARCHAR(30),
    age       INTEGER,
    CONSTRAINT chk_emp_fullname CHECK (TRIM(fullname) <> ''),
    CONSTRAINT chk_emp_age      CHECK (age IS NULL OR (age > 0 AND age < 150))
);

-- tags and wiki_notes are stored as INTEGER arrays referencing tag and wiki_note tables.
-- notes is a JSONB array for inline, row-scoped free-form notes.
CREATE TABLE learning_material (
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    description   TEXT,
    link          VARCHAR(100),
    price         INTEGER,
    type_id       INTEGER NOT NULL,
    tag_ids       INTEGER[] NOT NULL DEFAULT '{}',
    wiki_note_ids INTEGER[] NOT NULL DEFAULT '{}',
    notes         JSONB     NOT NULL DEFAULT '[]',
    CONSTRAINT fk_lm_type   FOREIGN KEY (type_id) REFERENCES learning_material_type(id) ON DELETE RESTRICT,
    CONSTRAINT chk_lm_name  CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_lm_price CHECK (price IS NULL OR price >= 0)
);

CREATE TABLE learning_path (
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          VARCHAR(20) NOT NULL,
    type_id       INTEGER NOT NULL,
    tag_ids       INTEGER[] NOT NULL DEFAULT '{}',
    wiki_note_ids INTEGER[] NOT NULL DEFAULT '{}',
    notes         JSONB     NOT NULL DEFAULT '[]',
    CONSTRAINT fk_lp_type  FOREIGN KEY (type_id) REFERENCES learning_path_type(id) ON DELETE RESTRICT,
    CONSTRAINT chk_lp_name CHECK (TRIM(name) <> '')
);

CREATE TABLE employee_group (
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    groupname     VARCHAR(30) NOT NULL,
    purpose       VARCHAR(30),
    tag_ids       INTEGER[] NOT NULL DEFAULT '{}',
    wiki_note_ids INTEGER[] NOT NULL DEFAULT '{}',
    notes         JSONB     NOT NULL DEFAULT '[]',
    CONSTRAINT chk_eg_groupname CHECK (TRIM(groupname) <> '')
);

-- ============================================================
-- BINDING TABLES
-- All use a composite primary key and ON DELETE CASCADE on both
-- foreign keys so that deleting either referenced entity removes
-- the binding row automatically.
-- ============================================================

CREATE TABLE employee_has_learning_path (
    employee_id      INTEGER NOT NULL,
    learning_path_id INTEGER NOT NULL,
    CONSTRAINT pk_ehlp PRIMARY KEY (employee_id, learning_path_id),
    CONSTRAINT fk_ehlp_employee      FOREIGN KEY (employee_id)      REFERENCES employee(id)      ON DELETE CASCADE,
    CONSTRAINT fk_ehlp_learning_path FOREIGN KEY (learning_path_id) REFERENCES learning_path(id) ON DELETE CASCADE
);

CREATE TABLE employee_has_learning_material (
    employee_id          INTEGER NOT NULL,
    learning_material_id INTEGER NOT NULL,
    CONSTRAINT pk_ehlm PRIMARY KEY (employee_id, learning_material_id),
    CONSTRAINT fk_ehlm_employee          FOREIGN KEY (employee_id)          REFERENCES employee(id)          ON DELETE CASCADE,
    CONSTRAINT fk_ehlm_learning_material FOREIGN KEY (learning_material_id) REFERENCES learning_material(id) ON DELETE CASCADE
);

CREATE TABLE learning_path_has_learning_material (
    learning_path_id     INTEGER NOT NULL,
    learning_material_id INTEGER NOT NULL,
    CONSTRAINT pk_lplm PRIMARY KEY (learning_path_id, learning_material_id),
    CONSTRAINT fk_lplm_learning_path     FOREIGN KEY (learning_path_id)     REFERENCES learning_path(id)     ON DELETE CASCADE,
    CONSTRAINT fk_lplm_learning_material FOREIGN KEY (learning_material_id) REFERENCES learning_material(id) ON DELETE CASCADE
);

CREATE TABLE employee_group_has_employee (
    employee_group_id INTEGER NOT NULL,
    employee_id       INTEGER NOT NULL,
    CONSTRAINT pk_eghe PRIMARY KEY (employee_group_id, employee_id),
    CONSTRAINT fk_eghe_employee_group FOREIGN KEY (employee_group_id) REFERENCES employee_group(id) ON DELETE CASCADE,
    CONSTRAINT fk_eghe_employee       FOREIGN KEY (employee_id)       REFERENCES employee(id)       ON DELETE CASCADE
);

CREATE TABLE employee_group_has_learning_path (
    employee_group_id INTEGER NOT NULL,
    learning_path_id  INTEGER NOT NULL,
    CONSTRAINT pk_eghlp PRIMARY KEY (employee_group_id, learning_path_id),
    CONSTRAINT fk_eghlp_employee_group FOREIGN KEY (employee_group_id) REFERENCES employee_group(id) ON DELETE CASCADE,
    CONSTRAINT fk_eghlp_learning_path  FOREIGN KEY (learning_path_id)  REFERENCES learning_path(id)  ON DELETE CASCADE
);

CREATE TABLE employee_group_has_learning_material (
    employee_group_id    INTEGER NOT NULL,
    learning_material_id INTEGER NOT NULL,
    CONSTRAINT pk_eghlm PRIMARY KEY (employee_group_id, learning_material_id),
    CONSTRAINT fk_eghlm_employee_group    FOREIGN KEY (employee_group_id)    REFERENCES employee_group(id)    ON DELETE CASCADE,
    CONSTRAINT fk_eghlm_learning_material FOREIGN KEY (learning_material_id) REFERENCES learning_material(id) ON DELETE CASCADE
);

-- ============================================================
-- TRIGGER FUNCTIONS
-- SET search_path = teamup ensures table references resolve
-- correctly regardless of the calling session's search_path.
-- ============================================================

-- Removes the deleted tag's ID from every entity that references it.
CREATE OR REPLACE FUNCTION fn_cascade_delete_tag()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = teamup
AS $$
BEGIN
    UPDATE learning_material SET tag_ids = array_remove(tag_ids, OLD.id)
        WHERE OLD.id = ANY(tag_ids);
    UPDATE learning_path     SET tag_ids = array_remove(tag_ids, OLD.id)
        WHERE OLD.id = ANY(tag_ids);
    UPDATE employee_group    SET tag_ids = array_remove(tag_ids, OLD.id)
        WHERE OLD.id = ANY(tag_ids);
    RETURN OLD;
END;
$$;

-- Removes the deleted wiki_note's ID from every entity that references it.
CREATE OR REPLACE FUNCTION fn_cascade_delete_wiki_note()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = teamup
AS $$
BEGIN
    UPDATE learning_material SET wiki_note_ids = array_remove(wiki_note_ids, OLD.id)
        WHERE OLD.id = ANY(wiki_note_ids);
    UPDATE learning_path     SET wiki_note_ids = array_remove(wiki_note_ids, OLD.id)
        WHERE OLD.id = ANY(wiki_note_ids);
    UPDATE employee_group    SET wiki_note_ids = array_remove(wiki_note_ids, OLD.id)
        WHERE OLD.id = ANY(wiki_note_ids);
    RETURN OLD;
END;
$$;

-- Validates that every ID in the tag_ids array exists in the tag table.
CREATE OR REPLACE FUNCTION fn_validate_tag_ids()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = teamup
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    FOREACH v_id IN ARRAY COALESCE(NEW.tag_ids, '{}')
    LOOP
        IF NOT EXISTS (SELECT 1 FROM tag WHERE id = v_id) THEN
            RAISE EXCEPTION 'Referential integrity error: tag_id % does not exist in tag table', v_id
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$;

-- Validates that every ID in the wiki_note_ids array exists in the wiki_note table.
CREATE OR REPLACE FUNCTION fn_validate_wiki_note_ids()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = teamup
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    FOREACH v_id IN ARRAY COALESCE(NEW.wiki_note_ids, '{}')
    LOOP
        IF NOT EXISTS (SELECT 1 FROM wiki_note WHERE id = v_id) THEN
            RAISE EXCEPTION 'Referential integrity error: wiki_note_id % does not exist in wiki_note table', v_id
                USING ERRCODE = 'foreign_key_violation';
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGERS: CASCADE DELETE
-- ============================================================

CREATE TRIGGER trg_cascade_delete_tag
    BEFORE DELETE ON tag
    FOR EACH ROW EXECUTE FUNCTION fn_cascade_delete_tag();

CREATE TRIGGER trg_cascade_delete_wiki_note
    BEFORE DELETE ON wiki_note
    FOR EACH ROW EXECUTE FUNCTION fn_cascade_delete_wiki_note();

-- ============================================================
-- TRIGGERS: ARRAY REFERENTIAL INTEGRITY
-- OF tag_ids / wiki_note_ids limits UPDATE firing to only when
-- those columns change; INSERT always fires the trigger.
-- ============================================================

CREATE TRIGGER trg_validate_lm_tag_ids
    BEFORE INSERT OR UPDATE OF tag_ids ON learning_material
    FOR EACH ROW EXECUTE FUNCTION fn_validate_tag_ids();

CREATE TRIGGER trg_validate_lp_tag_ids
    BEFORE INSERT OR UPDATE OF tag_ids ON learning_path
    FOR EACH ROW EXECUTE FUNCTION fn_validate_tag_ids();

CREATE TRIGGER trg_validate_eg_tag_ids
    BEFORE INSERT OR UPDATE OF tag_ids ON employee_group
    FOR EACH ROW EXECUTE FUNCTION fn_validate_tag_ids();

CREATE TRIGGER trg_validate_lm_wiki_note_ids
    BEFORE INSERT OR UPDATE OF wiki_note_ids ON learning_material
    FOR EACH ROW EXECUTE FUNCTION fn_validate_wiki_note_ids();

CREATE TRIGGER trg_validate_lp_wiki_note_ids
    BEFORE INSERT OR UPDATE OF wiki_note_ids ON learning_path
    FOR EACH ROW EXECUTE FUNCTION fn_validate_wiki_note_ids();

CREATE TRIGGER trg_validate_eg_wiki_note_ids
    BEFORE INSERT OR UPDATE OF wiki_note_ids ON employee_group
    FOR EACH ROW EXECUTE FUNCTION fn_validate_wiki_note_ids();

-- ============================================================
-- INDEXES
-- GIN indexes accelerate array containment queries (e.g. WHERE x = ANY(tag_ids)).
-- ============================================================

CREATE INDEX idx_lm_tag_ids        ON learning_material USING GIN (tag_ids);
CREATE INDEX idx_lm_wiki_note_ids  ON learning_material USING GIN (wiki_note_ids);
CREATE INDEX idx_lp_tag_ids        ON learning_path     USING GIN (tag_ids);
CREATE INDEX idx_lp_wiki_note_ids  ON learning_path     USING GIN (wiki_note_ids);
CREATE INDEX idx_eg_tag_ids        ON employee_group    USING GIN (tag_ids);
CREATE INDEX idx_eg_wiki_note_ids  ON employee_group    USING GIN (wiki_note_ids);
