--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Ubuntu 11.5-1)
-- Dumped by pg_dump version 11.5 (Ubuntu 11.5-1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authors (
    id integer NOT NULL,
    first character varying(255),
    middle character varying(255),
    last character varying(255) NOT NULL,
    "full" character varying(255) NOT NULL,
    short character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: authors_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authors_books (
    book_id integer,
    author_id integer
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authors_id_seq OWNED BY public.authors.id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: lots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lots (
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lots_id_seq OWNED BY public.lots.id;


--
-- Name: oz_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oz_books (
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

CREATE SEQUENCE public.oz_books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oz_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oz_books_id_seq OWNED BY public.oz_books.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    unconfirmed_email character varying(255),
    authentication_token character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nickname character varying(20) NOT NULL,
    skypename character varying(34),
    phone character varying(25),
    cityid integer DEFAULT '-1'::integer NOT NULL,
    admin boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors ALTER COLUMN id SET DEFAULT nextval('public.authors_id_seq'::regclass);


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: lots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lots ALTER COLUMN id SET DEFAULT nextval('public.lots_id_seq'::regclass);


--
-- Name: oz_books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oz_books ALTER COLUMN id SET DEFAULT nextval('public.oz_books_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: oz_books oz_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oz_books
    ADD CONSTRAINT oz_books_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: author_name_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX author_name_ts ON public.authors USING gin (to_tsvector('russian'::regconfig, ("full")::text));


--
-- Name: authors_full_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authors_full_lower ON public.authors USING btree (lower(("full")::text) varchar_pattern_ops);


--
-- Name: authors_last_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authors_last_lower ON public.authors USING btree (lower((last)::text) varchar_pattern_ops);


--
-- Name: book_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX book_title ON public.books USING btree (lower((title)::text) varchar_pattern_ops);


--
-- Name: book_title_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX book_title_ts ON public.books USING gin (to_tsvector('russian'::regconfig, (title)::text));


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_authors_books_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_books_on_author_id ON public.authors_books USING btree (author_id);


--
-- Name: index_authors_books_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_books_on_book_id ON public.authors_books USING btree (book_id);


--
-- Name: index_authors_on_full; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_full ON public.authors USING btree ("full");


--
-- Name: index_authors_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_id ON public.authors USING btree (id);


--
-- Name: index_authors_on_last_and_first_and_middle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_last_and_first_and_middle ON public.authors USING btree (last, first, middle);


--
-- Name: index_books_on_genre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_genre ON public.books USING btree (genre);


--
-- Name: index_books_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_id ON public.books USING btree (id);


--
-- Name: index_lots_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_book_id ON public.lots USING btree (book_id);


--
-- Name: index_lots_on_cityid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_cityid ON public.lots USING btree (cityid);


--
-- Name: index_lots_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_id ON public.lots USING btree (id);


--
-- Name: index_lots_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_user_id ON public.lots USING btree (user_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON public.users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_nickname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_nickname ON public.users USING btree (nickname);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: ozbook_auth_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_auth_all ON public.oz_books USING btree (lower((auth_all)::text) varchar_pattern_ops);


--
-- Name: ozbook_auth_last; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_auth_last ON public.oz_books USING btree (lower((auth_last)::text) varchar_pattern_ops);


--
-- Name: ozbook_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ozbook_title ON public.oz_books USING btree (lower((title)::text) varchar_pattern_ops);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


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