--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authors (
    id integer NOT NULL,
    first character varying(255),
    middle character varying(255),
    last character varying(255) NOT NULL,
    "full" character varying(255) NOT NULL,
    short character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authors_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authors_books (
    book_id integer,
    author_id integer
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authors_id_seq OWNED BY authors.id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE books (
    id integer NOT NULL,
    title character varying(255),
    ozon_coverid character varying(255),
    ozonid character varying(255),
    coverpath_x300 character varying(255),
    coverpath_x200 character varying(255),
    coverpath_x120 character varying(255),
    genre integer DEFAULT 0,
    lots_count integer DEFAULT 0,
    min_price integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE books_id_seq OWNED BY books.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: lots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lots (
    id integer NOT NULL,
    user_id integer NOT NULL,
    book_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    price integer,
    comment character varying(255),
    can_deliver boolean DEFAULT false,
    can_postmail boolean DEFAULT false,
    skypename character varying(34),
    phone character varying(25),
    cityid integer NOT NULL,
    cover_file_name character varying(255),
    cover_content_type character varying(255),
    cover_file_size integer,
    cover_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lots_id_seq OWNED BY lots.id;


--
-- Name: oz_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oz_books (
    id integer NOT NULL,
    title character varying(255),
    ozon_coverid character varying(255),
    ozonid integer,
    genre integer,
    auth_last character varying(255),
    auth_all character varying(255)
);


--
-- Name: oz_books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oz_books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oz_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oz_books_id_seq OWNED BY oz_books.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    authentication_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nickname character varying(20) NOT NULL,
    skypename character varying(34),
    phone character varying(25),
    cityid integer DEFAULT '-1'::integer NOT NULL,
    admin boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors ALTER COLUMN id SET DEFAULT nextval('authors_id_seq'::regclass);


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ALTER COLUMN id SET DEFAULT nextval('books_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: lots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lots ALTER COLUMN id SET DEFAULT nextval('lots_id_seq'::regclass);


--
-- Name: oz_books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oz_books ALTER COLUMN id SET DEFAULT nextval('oz_books_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: active_admin_comments admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: oz_books oz_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oz_books
    ADD CONSTRAINT oz_books_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: author_name_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX author_name_ts ON authors USING gin (to_tsvector('russian'::regconfig, ("full")::text));


--
-- Name: authors_full_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authors_full_lower ON authors USING btree (lower(("full")::text) varchar_pattern_ops);


--
-- Name: authors_last_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authors_last_lower ON authors USING btree (lower((last)::text) varchar_pattern_ops);


--
-- Name: book_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX book_title ON books USING btree (lower((title)::text) varchar_pattern_ops);


--
-- Name: book_title_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX book_title_ts ON books USING gin (to_tsvector('russian'::regconfig, (title)::text));


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_authors_books_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_books_on_author_id ON authors_books USING btree (author_id);


--
-- Name: index_authors_books_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_books_on_book_id ON authors_books USING btree (book_id);


--
-- Name: index_authors_on_full; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_full ON authors USING btree ("full");


--
-- Name: index_authors_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_id ON authors USING btree (id);


--
-- Name: index_authors_on_last_and_first_and_middle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_last_and_first_and_middle ON authors USING btree (last, first, middle);


--
-- Name: index_books_on_genre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_genre ON books USING btree (genre);


--
-- Name: index_books_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_id ON books USING btree (id);


--
-- Name: index_lots_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_book_id ON lots USING btree (book_id);


--
-- Name: index_lots_on_cityid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_cityid ON lots USING btree (cityid);


--
-- Name: index_lots_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_id ON lots USING btree (id);


--
-- Name: index_lots_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_user_id ON lots USING btree (user_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_nickname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_nickname ON users USING btree (nickname);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: ozbook_auth_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_auth_all ON oz_books USING btree (lower((auth_all)::text) varchar_pattern_ops);


--
-- Name: ozbook_auth_last; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_auth_last ON oz_books USING btree (lower((auth_last)::text) varchar_pattern_ops);


--
-- Name: ozbook_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_title ON oz_books USING btree (lower((title)::text) varchar_pattern_ops);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20111227163009');

INSERT INTO schema_migrations (version) VALUES ('20120108162833');

INSERT INTO schema_migrations (version) VALUES ('20120117143222');

INSERT INTO schema_migrations (version) VALUES ('20120122185045');

INSERT INTO schema_migrations (version) VALUES ('20120122185229');

INSERT INTO schema_migrations (version) VALUES ('20120124161034');

INSERT INTO schema_migrations (version) VALUES ('20120630135901');

INSERT INTO schema_migrations (version) VALUES ('20120708164433');

INSERT INTO schema_migrations (version) VALUES ('20120710094227');

INSERT INTO schema_migrations (version) VALUES ('20120715123926');

INSERT INTO schema_migrations (version) VALUES ('20120719155712');

INSERT INTO schema_migrations (version) VALUES ('20120719155713');