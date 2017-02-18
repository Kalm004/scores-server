-----------------------------------------------------------------------------------------
-- Setup Role and Schema                                                                           --
-----------------------------------------------------------------------------------------
CREATE ROLE scores_role LOGIN
NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

ALTER ROLE scores_role PASSWORD 'scores_pass';

CREATE DATABASE scores_db
WITH OWNER = scores_role
ENCODING = 'UTF8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1;

CREATE SCHEMA scores_schema;

-----------------------------------------------------------------------------------------
-- Functions                                                                           --
-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION scores_schema.update_modified_column()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.modified := now();
  RETURN NEW;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------------------------
-- Tables                                                                              --
-----------------------------------------------------------------------------------------
CREATE TABLE scores_schema.tm_player (
  id          SERIAL                      NOT NULL PRIMARY KEY,
  name        CHARACTER VARYING(150)      NOT NULL,
  email       CHARACTER VARYING(100)      NOT NULL UNIQUE,
  salt        CHARACTER VARYING(128)      NOT NULL,
  hashed_pass CHARACTER VARYING(128)      NOT NULL,
  active      BOOLEAN                     NOT NULL DEFAULT TRUE,

  created     TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tm_player
BEFORE UPDATE
  ON scores_schema.tm_player
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();


CREATE TABLE scores_schema.tm_game (
  id       SERIAL                      NOT NULL PRIMARY KEY,
  name     CHARACTER VARYING(150)      NOT NULL,
  api_key  CHARACTER VARYING(150)      NOT NULL UNIQUE,

  created  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tm_game
BEFORE UPDATE
  ON scores_schema.tm_game
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();


CREATE TABLE scores_schema.tm_manager (
  id          SERIAL                      NOT NULL PRIMARY KEY,
  name        CHARACTER VARYING(50)       NOT NULL,
  email       CHARACTER VARYING(100)      NOT NULL,
  salt        CHARACTER VARYING(128)      NOT NULL,
  hashed_pass CHARACTER VARYING(128)      NOT NULL,
  active      BOOLEAN                     NOT NULL DEFAULT TRUE,

  created     TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tm_manager
BEFORE UPDATE
  ON scores_schema.tm_manager
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();


CREATE TABLE scores_schema.tm_level (
  id       SERIAL                      NOT NULL PRIMARY KEY,
  name     CHARACTER VARYING(50)       NOT NULL,
  game_id  INTEGER                     NOT NULL REFERENCES scores_schema.tm_game (id),

  created  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tm_level
BEFORE UPDATE
  ON scores_schema.tm_level
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();

-- Relation tables
CREATE TABLE scores_schema.tr_score (
  value     INTEGER                     NOT NULL,
  player_id INTEGER                     NOT NULL REFERENCES scores_schema.tm_player (id),
  level_id  INTEGER                     NOT NULL REFERENCES scores_schema.tm_level (id),
  PRIMARY KEY (player_id, level_id),

  created   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tr_score
BEFORE UPDATE
  ON scores_schema.tr_score
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();

CREATE TABLE scores_schema.tr_manager_game (
  manager_id INTEGER                     NOT NULL REFERENCES scores_schema.tm_manager (id),
  game_id    INTEGER                     NOT NULL REFERENCES scores_schema.tm_game (id),
  PRIMARY KEY (manager_id, game_id),

  created    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  modified   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_bu_tr_manager_game
BEFORE UPDATE
  ON scores_schema.tr_manager_game
FOR EACH ROW
EXECUTE PROCEDURE scores_schema.update_modified_column();