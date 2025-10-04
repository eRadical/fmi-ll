
DROP TABLE IF EXISTS actor;
CREATE TABLE actor (
    actor_id smallserial NOT NULL,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_actor" PRIMARY KEY (actor_id)
);

DROP TABLE IF EXISTS category;
CREATE TABLE category (
    category_id smallserial NOT NULL,
    "name" varchar(25) NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_category" PRIMARY KEY (category_id)
);

DROP TABLE IF EXISTS country;
CREATE TABLE country (
    country_id smallserial NOT NULL,
    country varchar(50) NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_country" PRIMARY KEY (country_id)
);

DROP TABLE IF EXISTS film_text;
CREATE TABLE film_text (
    film_id int2 NOT NULL,
    title varchar(255) NOT NULL,
    description text NULL,
    CONSTRAINT "PRIMARY_film_text" PRIMARY KEY (film_id)
);

DROP TABLE IF EXISTS "language";
CREATE TABLE "language" (
    language_id smallserial NOT NULL,
    "name" bpchar(20) NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_language" PRIMARY KEY (language_id)
);

DROP TABLE IF EXISTS city;
CREATE TABLE city (
    city_id smallserial NOT NULL,
    city varchar(50) NOT NULL,
    country_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_city" PRIMARY KEY (city_id)
);

DROP TABLE IF EXISTS film;
CREATE TABLE film (
    film_id smallserial NOT NULL,
    title varchar(255) NOT NULL,
    description text NULL,
    release_year int2 NULL,
    language_id int2 NOT NULL,
    original_language_id int2 NULL,
    rental_duration int2 DEFAULT 3 NOT NULL,
    rental_rate numeric(4, 2) DEFAULT 4.99 NOT NULL,
    length int2 NULL,
    replacement_cost numeric(5, 2) DEFAULT 19.99 NOT NULL,
    rating varchar(10) DEFAULT 'G'::character varying NULL,
    special_features varchar(60) DEFAULT NULL::character varying NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_film" PRIMARY KEY (film_id)
);

DROP TABLE IF EXISTS film_actor;
CREATE TABLE film_actor (
    actor_id int2 NOT NULL,
    film_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_film_actor" PRIMARY KEY (actor_id, film_id)
);

DROP TABLE IF EXISTS film_category;
CREATE TABLE film_category (
    film_id int2 NOT NULL,
    category_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_film_category" PRIMARY KEY (film_id, category_id)
);

DROP TABLE IF EXISTS address;
CREATE TABLE address (
    address_id smallserial NOT NULL,
    address varchar(50) NOT NULL,
    address2 varchar(50) NULL,
    district varchar(20) NOT NULL,
    city_id int2 NOT NULL,
    postal_code varchar(10) NULL,
    phone varchar(20) NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_address" PRIMARY KEY (address_id)
);

DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    customer_id smallserial NOT NULL,
    store_id int2 NOT NULL,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    email varchar(50) NULL,
    address_id int2 NOT NULL,
    active int2 DEFAULT 1 NOT NULL,
    create_date timestamp NOT NULL,
    last_update timestamp DEFAULT now() NULL,
    CONSTRAINT "PRIMARY_customer" PRIMARY KEY (customer_id)
);

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    inventory_id int4 NOT NULL,
    film_id int2 NOT NULL,
    store_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_inventory" PRIMARY KEY (inventory_id)
);

DROP TABLE IF EXISTS payment;
CREATE TABLE payment (
    payment_id smallserial NOT NULL,
    customer_id int2 NOT NULL,
    staff_id int2 NOT NULL,
    rental_id int4 NULL,
    amount numeric(5, 2) NOT NULL,
    payment_date timestamp NOT NULL,
    last_update timestamp DEFAULT now() NULL,
    CONSTRAINT "PRIMARY_payment" PRIMARY KEY (payment_id)
);

DROP TABLE IF EXISTS rental;
CREATE TABLE rental (
    rental_id serial4 NOT NULL,
    rental_date timestamp NOT NULL,
    inventory_id int4 NOT NULL,
    customer_id int2 NOT NULL,
    return_date timestamp NULL,
    staff_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_rental" PRIMARY KEY (rental_id),
    CONSTRAINT rental_date UNIQUE (rental_date, inventory_id, customer_id)
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    staff_id smallserial NOT NULL,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    address_id int2 NOT NULL,
    picture bytea NULL,
    email varchar(50) NULL,
    store_id int2 NOT NULL,
    active int2 DEFAULT 1 NOT NULL,
    username varchar(16) NOT NULL,
    "password" varchar(40) NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_staff" PRIMARY KEY (staff_id)
);

DROP TABLE IF EXISTS store;
CREATE TABLE store (
    store_id smallserial NOT NULL,
    manager_staff_id int2 NOT NULL,
    address_id int2 NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "PRIMARY_store" PRIMARY KEY (store_id),
    CONSTRAINT store_manager_staff_id_key UNIQUE (manager_staff_id)
);
