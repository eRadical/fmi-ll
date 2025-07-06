CREATE USER sakila  with encrypted password 'sakila';
GRANT sakila  to postgres;

create database sakila;
grant all privileges on database sakila to sakila;
ALTER DATABASE sakila OWNER TO sakila;
