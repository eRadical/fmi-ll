-- public.actor definition

-- Drop table

-- DROP TABLE actor;

CREATE TABLE actor (
                       actor_id smallserial NOT NULL,
                       first_name varchar(45) NOT NULL,
                       last_name varchar(45) NOT NULL,
                       last_update timestamp DEFAULT now() NOT NULL,
                       CONSTRAINT "PRIMARY" PRIMARY KEY (actor_id)
);


-- public.category definition

-- Drop table

-- DROP TABLE category;

CREATE TABLE category (
                          category_id smallserial NOT NULL,
                          "name" varchar(25) NOT NULL,
                          last_update timestamp DEFAULT now() NOT NULL,
                          CONSTRAINT "PRIMARY_category" PRIMARY KEY (category_id)
);


-- public.country definition

-- Drop table

-- DROP TABLE country;

CREATE TABLE country (
                         country_id smallserial NOT NULL,
                         country varchar(50) NOT NULL,
                         last_update timestamp DEFAULT now() NOT NULL,
                         CONSTRAINT "PRIMARY_country" PRIMARY KEY (country_id)
);


-- public.film_text definition

-- Drop table

-- DROP TABLE film_text;

CREATE TABLE film_text (
                           film_id int2 NOT NULL,
                           title varchar(255) NOT NULL,
                           description text NULL,
                           CONSTRAINT "PRIMARY_film_text" PRIMARY KEY (film_id)
);


-- public."language" definition

-- Drop table

-- DROP TABLE "language";

CREATE TABLE "language" (
                            language_id smallserial NOT NULL,
                            "name" bpchar(20) NOT NULL,
                            last_update timestamp DEFAULT now() NOT NULL,
                            CONSTRAINT "PRIMARY_language" PRIMARY KEY (language_id)
);


-- public.city definition

-- Drop table

-- DROP TABLE city;

CREATE TABLE city (
                      city_id smallserial NOT NULL,
                      city varchar(50) NOT NULL,
                      country_id int2 NOT NULL,
                      last_update timestamp DEFAULT now() NOT NULL,
                      CONSTRAINT "PRIMARY_city" PRIMARY KEY (city_id),
                      CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- public.film definition

-- Drop table

-- DROP TABLE film;

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
                      special_features varchar(50) DEFAULT NULL::character varying NULL,
                      last_update timestamp DEFAULT now() NOT NULL,
                      CONSTRAINT "PRIMARY_film" PRIMARY KEY (film_id),
                      CONSTRAINT film_rating_check CHECK ((upper((rating)::text) = ANY (ARRAY['G'::text, 'PG'::text, 'PG-13'::text, 'R'::text, 'NC-17'::text]))),
                      CONSTRAINT film_special_features_check CHECK ((initcap((special_features)::text) = ANY (ARRAY['Trailers'::text, 'Commentaries'::text, 'Deleted Scenes'::text, 'Behind the Scenes'::text]))),
                      CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES "language"(language_id) ON DELETE RESTRICT ON UPDATE CASCADE,
                      CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES "language"(language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- public.film_actor definition

-- Drop table

-- DROP TABLE film_actor;

CREATE TABLE film_actor (
                            actor_id int2 NOT NULL,
                            film_id int2 NOT NULL,
                            last_update timestamp DEFAULT now() NOT NULL,
                            CONSTRAINT "PRIMARY_film_actor" PRIMARY KEY (actor_id, film_id),
                            CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
                            CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- public.film_category definition

-- Drop table

-- DROP TABLE film_category;

CREATE TABLE film_category (
                               film_id int2 NOT NULL,
                               category_id int2 NOT NULL,
                               last_update timestamp DEFAULT now() NOT NULL,
                               CONSTRAINT "PRIMARY_film_category" PRIMARY KEY (film_id, category_id),
                               CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
                               CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- public.address definition

-- Drop table

-- DROP TABLE address;

CREATE TABLE address (
                         address_id smallserial NOT NULL,
                         address varchar(50) NOT NULL,
                         address2 varchar(50) NULL,
                         district varchar(20) NOT NULL,
                         city_id int2 NOT NULL,
                         postal_code varchar(10) NULL,
                         phone varchar(20) NOT NULL,
                         last_update timestamp DEFAULT now() NOT NULL,
                         CONSTRAINT "PRIMARY_address" PRIMARY KEY (address_id),
                         CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city(city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- public.customer definition

-- Drop table

-- DROP TABLE customer;

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


-- public.inventory definition

-- Drop table

-- DROP TABLE inventory;

CREATE TABLE inventory (
                           inventory_id int4 NOT NULL,
                           film_id int2 NOT NULL,
                           store_id int2 NOT NULL,
                           last_update timestamp DEFAULT now() NOT NULL,
                           CONSTRAINT "PRIMARY_inventory" PRIMARY KEY (inventory_id)
);


-- public.payment definition

-- Drop table

-- DROP TABLE payment;

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


-- public.rental definition

-- Drop table

-- DROP TABLE rental;

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


-- public.staff definition

-- Drop table

-- DROP TABLE staff;

CREATE TABLE staff (
                       staff_id smallserial NOT NULL,
                       first_name varchar(45) NOT NULL,
                       last_name varchar(45) NOT NULL,
                       address_id int2 NOT NULL,
                       picture oid NULL,
                       email varchar(50) NULL,
                       store_id int2 NOT NULL,
                       active int2 DEFAULT 1 NOT NULL,
                       username varchar(16) NOT NULL,
                       "password" varchar(40) NULL,
                       last_update timestamp DEFAULT now() NOT NULL,
                       CONSTRAINT "PRIMARY_staff" PRIMARY KEY (staff_id)
);


-- public.store definition

-- Drop table

-- DROP TABLE store;

CREATE TABLE store (
                       store_id smallserial NOT NULL,
                       manager_staff_id int2 NOT NULL,
                       address_id int2 NOT NULL,
                       last_update timestamp DEFAULT now() NOT NULL,
                       CONSTRAINT "PRIMARY_store" PRIMARY KEY (store_id),
                       CONSTRAINT store_manager_staff_id_key UNIQUE (manager_staff_id)
);


-- public.customer foreign keys

ALTER TABLE public.customer ADD CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.customer ADD CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.inventory foreign keys

ALTER TABLE public.inventory ADD CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.inventory ADD CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.payment foreign keys

ALTER TABLE public.payment ADD CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.payment ADD CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.payment ADD CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.rental foreign keys

ALTER TABLE public.rental ADD CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.rental ADD CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.rental ADD CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.staff foreign keys

ALTER TABLE public.staff ADD CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.staff ADD CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE;


-- public.store foreign keys

ALTER TABLE public.store ADD CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.store ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;
