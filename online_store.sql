

/*******************************************************************************
   sample-database-online-electronics-store - Version 1.0
   
   Script:       online_store.sql
   Description:  Creates and populates the database.
   DB Server:    ORACLE
   Author:       Michal Wisniewski
   Assignment:   Project to learn and practice designing a simple database
********************************************************************************/

/*******************************************************************************
   Drop database if it exists
********************************************************************************/

DROP USER c##online_store CASCADE;

/*******************************************************************************
   Create Database (If you are getting an error related to creating a user 
   i.e. you are using a database type other than pluggable database remove the 
   prefix "c##" from the user name in the following script)
             |
             V    
********************************************************************************/

CREATE USER c##online_store
IDENTIFIED BY 123
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 10M ON users;

GRANT CREATE SESSION TO c##online_store;
GRANT CREATE TABLE TO c##online_store;
GRANT CREATE SEQUENCE TO c##online_store;
GRANT CREATE VIEW TO c##online_store;
GRANT CREATE PROCEDURE TO c##online_store;
GRANT CREATE TRIGGER TO c##online_store;

CONNECT c##online_store/123

/*******************************************************************************
   Create Sequences
********************************************************************************/

/* Sequence for store_users.user_id column value */
   
CREATE SEQUENCE seq_store_users_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence product.product_id column value */

CREATE SEQUENCE seq_product_product_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for discount.discount_id column value */

CREATE SEQUENCE seq_discount_discount_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for cart_item.cart_item_id column value */

CREATE SEQUENCE seq_cart_item_cart_item_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for shopping_session.session_id column value */

CREATE SEQUENCE seq_shopping_session_session_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for order_details.order_details_id column value */

CREATE SEQUENCE seq_order_details_order_detail_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for order_items.order_items_id column value */

CREATE SEQUENCE seq_order_items_order_items_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for payment_details.payment_details_id column value */

CREATE SEQUENCE seq_payment_details_payment_details_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for employees.employee_id column value */

CREATE SEQUENCE seq_employees_employee_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/* Sequence for departments.department_id column value */

CREATE SEQUENCE seq_departments_department_id
START WITH 1
INCREMENT BY 1
NOCACHE;

/*******************************************************************************
   Create Tables
********************************************************************************/

/* A table containing users registered on the store's website */

CREATE TABLE store_users
(
 user_id        INTEGER DEFAULT seq_store_users_id.nextval PRIMARY KEY,
 first_name     VARCHAR2(80) NOT NULL,
 middle_name    VARCHAR2(80),
 last_name      VARCHAR2(80) NOT NULL,
 phone_number   VARCHAR2(30) UNIQUE NOT NULL 
                                    CONSTRAINT check_phone_number_store_users 
                                    CHECK (REGEXP_LIKE(phone_number, '^\d{3}.\d{3}.\d{4}$')),
 email          VARCHAR2(80) UNIQUE NOT NULL,
 username       VARCHAR2(30) UNIQUE NOT NULL,
 user_password  VARCHAR2(30) NOT NULL,
 registered_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

/* A table containing products categories */

CREATE TABLE product_categories
(
 category_id    INTEGER PRIMARY KEY,
 category_name  VARCHAR2(80) NOT NULL
);

/* A table containing the products that the store sells */

CREATE TABLE product
(
 product_id         INTEGER DEFAULT seq_product_product_id.nextval PRIMARY KEY,
 product_name       VARCHAR2(500) NOT NULL,
 category_id        INTEGER NOT NULL, 
 sku                VARCHAR2(20) NOT NULL,
 price              NUMBER NOT NULL,
 discount_id        INTEGER,
 created_at         TIMESTAMP,
 last_modified      TIMESTAMP,
 CONSTRAINT fk_category_id_tbl_product FOREIGN KEY (category_id)
 REFERENCES product_categories (category_id)
);

/* Table of active and expired promotions in the store */

CREATE TABLE discount
(
 discount_id        INTEGER DEFAULT seq_discount_discount_id.nextval PRIMARY KEY,
 discount_name      VARCHAR2(100) NOT NULL,
 discount_desc      VARCHAR2(200),
 discount_percent   NUMBER NOT NULL, 
 is_active_status   VARCHAR2(1) NOT NULL 
                                CONSTRAINT check_status 
                                CHECK (is_active_status IN ('Y', 'N')),
 created_at         TIMESTAMP,
 modified_at        TIMESTAMP
);

/* A table containing the products added to the cart by the customer in a specific session */

CREATE TABLE cart_item
(
 cart_item_id   INTEGER DEFAULT seq_cart_item_cart_item_id.nextval PRIMARY KEY,
 session_id     INTEGER NOT NULL,
 product_id     INTEGER NOT NULL,
 quantity       INTEGER NOT NULL,
 created_at     TIMESTAMP,
 modified_at    TIMESTAMP,
 CONSTRAINT fk_product_id_tbl_cart_item FOREIGN KEY (product_id)
 REFERENCES product (product_id)
);

/* Table containing sessions created by users */

CREATE TABLE shopping_session
(
 session_id     INTEGER DEFAULT seq_shopping_session_session_id.nextval PRIMARY KEY,
 user_id        INTEGER NOT NULL,
 created_at     TIMESTAMP,
 modified_at    TIMESTAMP,
 CONSTRAINT fk_user_id_tbl_shopping_session FOREIGN KEY (user_id)
 REFERENCES store_users (user_id)
);

/* Table with user order details */

CREATE TABLE order_details 
(
 order_details_id   INTEGER DEFAULT seq_order_details_order_detail_id.nextval PRIMARY KEY,
 user_id            INTEGER NOT NULL,
 total              NUMBER NOT NULL,
 payment_id         INTEGER NOT NULL,
 shipping_method    VARCHAR2(6) NOT NULL CONSTRAINT check_shipping_method CHECK(shipping_method IN ('DPD', 'DHL', 'UPS', 'Inpost')),
 delivery_adress_id INTEGER NOT NULL,
 created_at         TIMESTAMP,
 modified_at        TIMESTAMP,
 CONSTRAINT fk_user_id_tbl_order_details FOREIGN KEY (user_id)
 REFERENCES store_users (user_id)
);

/* A table containing the products in the order made by the user */

CREATE TABLE order_items
(
 order_items_id     INTEGER DEFAULT seq_order_items_order_items_id.nextval PRIMARY KEY,
 order_details_id   INTEGER NOT NULL,
 product_id         INTEGER NOT NULL,
 created_at         TIMESTAMP,
 modified_at        TIMESTAMP,
 CONSTRAINT fk_order_details_id_tbl_order_items FOREIGN KEY (order_details_id)
 REFERENCES order_details (order_details_id),
 CONSTRAINT fk_product_id_tbl_order_items FOREIGN KEY (product_id)
 REFERENCES product (product_id)
);

/* Table containing details of payment for the order */

CREATE TABLE payment_details
(
 payment_details_id     INTEGER DEFAULT seq_payment_details_payment_details_id.nextval 
                        PRIMARY KEY,
 order_id               INTEGER NOT NULL,
 amount                 NUMBER NOT NULL,
 provider               VARCHAR2(100) NOT NULL CONSTRAINT check_provider CHECK(provider IN ('PayPal','WildApricot Payments','Stripe','Bank of America')),
 payment_status         VARCHAR2(10) CONSTRAINT check_payment_status CHECK
                                     (payment_status IN ('PROCESSED', 'PENDING', 'FAILURE')),
 created_at             TIMESTAMP,
 modified_at            TIMESTAMP,
 CONSTRAINT fk_order_id_tbl_payment_details FOREIGN KEY (order_id)
 REFERENCES order_details (order_details_id)
);


ALTER TABLE product ADD
CONSTRAINT fk_discount_id_tbl_product FOREIGN KEY (discount_id)
REFERENCES discount (discount_id);

ALTER TABLE cart_item ADD
CONSTRAINT fk_session_id_tbl_cart_item FOREIGN KEY (session_id)
REFERENCES shopping_session (session_id);

ALTER TABLE order_details ADD
CONSTRAINT fk_payment_id_tbl_order_details FOREIGN KEY (payment_id)
REFERENCES payment_details (payment_details_id);

/* Table containing store employees */

CREATE TABLE employees
(
 employee_id    INTEGER DEFAULT seq_employees_employee_id.nextval PRIMARY KEY,
 first_name     VARCHAR2(80) NOT NULL,
 middle_name    VARCHAR2(80) NULL,
 last_name      VARCHAR2(80) NOT NULL,
 date_of_birth  DATE NOT NULL,
 department_id  INTEGER NOT NULL,
 hire_date      DATE NOT NULL,
 salary         NUMBER NOT NULL,
 phone_number   VARCHAR2(30) UNIQUE NULL 
                                    CONSTRAINT check_phone_number_employees 
                                    CHECK (REGEXP_LIKE(phone_number, '^\d{3}.\d{3}.\d{4}$')),
 email          VARCHAR2(80) UNIQUE NULL,
 ssn_number     VARCHAR2(20) NOT NULL,
 manager_id     INTEGER
);

/* Table of internal employee departments of the store */

CREATE TABLE departments
(
 department_id      INTEGER DEFAULT seq_departments_department_id.nextval PRIMARY KEY,
 department_name    VARCHAR2(100) NOT NULL,
 manager_id         INTEGER NOT NULL,
 department_desc    VARCHAR2(200) NULL,
 CONSTRAINT fk_manager_id_tbl_departments FOREIGN KEY (manager_id)
 REFERENCES employees (employee_id)
);

/* Table of customer addresses */

CREATE TABLE addresses 
(
 adress_id      INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 line_1         VARCHAR2(100) NOT NULL,
 line_2         VARCHAR2(100),
 city           VARCHAR2(80) NOT NULL,
 zip_code       VARCHAR2(20) NOT NULL,
 province       VARCHAR2(80),
 country        VARCHAR2(80) NOT NULL
);

/* Table containing archived employee data - new rows added, rows updated and rows deleted, 
   along with information about the time of modification and also about the user who made the changes */

CREATE TABLE employees_archive
(
 event_date		    DATE,
 event_type 	    VARCHAR2(20 BYTE),
 user_name 			VARCHAR2(20 BYTE),
 old_employee_id    INTEGER,
 old_first_name     VARCHAR2(80),
 old_middle_name    VARCHAR2(80),
 old_last_name      VARCHAR2(80),
 old_date_of_birth  DATE,
 old_department_id  INTEGER,
 old_hire_date      DATE,
 old_salary         NUMBER,
 old_phone_number   VARCHAR2(30),
 old_email          VARCHAR2(80),
 old_ssn_number     VARCHAR2(11 CHAR),
 old_manager_id     INTEGER,
 new_employee_id    INTEGER,
 new_first_name     VARCHAR2(80),
 new_middle_name    VARCHAR2(80),
 new_last_name      VARCHAR2(80),
 new_date_of_birth  DATE,
 new_department_id  INTEGER,
 new_hire_date      DATE,
 new_salary         NUMBER,
 new_phone_number   VARCHAR2(30),
 new_email          VARCHAR2(80),
 new_ssn_number     VARCHAR2(11 CHAR),
 new_manager_id     INTEGER
);


ALTER TABLE employees 
ADD  CONSTRAINT fk_department_id_tbl_employees FOREIGN KEY (department_id)
REFERENCES departments (department_id);

ALTER TABLE employees 
ADD  CONSTRAINT fk_manager_id_tbl_employees FOREIGN KEY (manager_id)
REFERENCES employees (employee_id);

ALTER TABLE order_details 
ADD  CONSTRAINT fk_delivery_adress_id_tbl_order_details FOREIGN KEY (delivery_adress_id)
REFERENCES addresses (adress_id);

/* Table containing product stock inventory */

CREATE TABLE stock
(
 product_id             INTEGER PRIMARY KEY,
 quantity               NUMBER NOT NULL,
 max_stock_quantity     NUMBER NOT NULL,
 unit                   VARCHAR2(10) NOT NULL,
 CONSTRAINT fk_product_id_tbl_stock FOREIGN KEY (product_id)
 REFERENCES product(product_id)
);

/*******************************************************************************
   Create Triggers
********************************************************************************/

/* Creation of an employee archive trigger - the values of the 
   employees table are inserted into the employees_archive table 
   depending on the operation being performed - 
   insert, update, or delete */
    
    
    CREATE OR REPLACE TRIGGER trigger_archiving_employees
	AFTER INSERT OR UPDATE OR DELETE
	ON employees
	FOR EACH ROW
	DECLARE
	BEGIN
        IF INSERTING THEN
			INSERT INTO employees_archive
		   (  EVENT_DATE	      
			, EVENT_TYPE          
			, USER_NAME           
			, OLD_EMPLOYEE_ID			  
			, OLD_FIRST_NAME 			  
			, OLD_MIDDLE_NAME 		  
			, OLD_LAST_NAME 
            , OLD_DATE_OF_BIRTH
			, OLD_DEPARTMENT_ID 
            , OLD_HIRE_DATE
			, OLD_SALARY  
			, OLD_PHONE_NUMBER 		  
			, OLD_EMAIL
            , OLD_SSN_NUMBER
            , OLD_MANAGER_ID
            , NEW_EMPLOYEE_ID			  
			, NEW_FIRST_NAME 			  
			, NEW_MIDDLE_NAME 		  
			, NEW_LAST_NAME 
            , NEW_DATE_OF_BIRTH
			, NEW_DEPARTMENT_ID 
            , NEW_HIRE_DATE
			, NEW_SALARY  
			, NEW_PHONE_NUMBER 		  
			, NEW_EMAIL
            , NEW_SSN_NUMBER
            , NEW_MANAGER_ID
			
			)
			VALUES
			(
			  SYSDATE
			, 'INSERT'
			, USER
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
            , NULL
            , NULL
            , NULL
            , NULL
			, :NEW.EMPLOYEE_ID			  
			, :NEW.FIRST_NAME 			  
			, :NEW.MIDDLE_NAME 		  
			, :NEW.LAST_NAME 
            , :NEW.DATE_OF_BIRTH
			, :NEW.DEPARTMENT_ID 
            , :NEW.HIRE_DATE
			, :NEW.SALARY  
			, :NEW.PHONE_NUMBER 		  
			, :NEW.EMAIL
            , :NEW.SSN_NUMBER
            , :NEW.MANAGER_ID
			);
		
        ELSIF UPDATING THEN
        
			INSERT INTO employees_archive
		   (  EVENT_DATE	      
			, EVENT_TYPE          
			, USER_NAME           
			, OLD_EMPLOYEE_ID			  
			, OLD_FIRST_NAME 			  
			, OLD_MIDDLE_NAME 		  
			, OLD_LAST_NAME 
            , OLD_DATE_OF_BIRTH
			, OLD_DEPARTMENT_ID 
            , OLD_HIRE_DATE
			, OLD_SALARY  
			, OLD_PHONE_NUMBER 		  
			, OLD_EMAIL
            , OLD_SSN_NUMBER
            , OLD_MANAGER_ID
            , NEW_EMPLOYEE_ID			  
			, NEW_FIRST_NAME 			  
			, NEW_MIDDLE_NAME 		  
			, NEW_LAST_NAME 
            , NEW_DATE_OF_BIRTH
			, NEW_DEPARTMENT_ID 
            , NEW_HIRE_DATE
			, NEW_SALARY  
			, NEW_PHONE_NUMBER 		  
			, NEW_EMAIL
            , NEW_SSN_NUMBER
            , NEW_MANAGER_ID
			)
			VALUES
			(
			  SYSDATE
			, 'INSERT'
			, USER
			, :OLD.EMPLOYEE_ID			  
			, :OLD.FIRST_NAME 			  
			, :OLD.MIDDLE_NAME 		  
			, :OLD.LAST_NAME 
            , :OLD.DATE_OF_BIRTH
			, :OLD.DEPARTMENT_ID
            , :OLD.HIRE_DATE
			, :OLD.SALARY  
			, :OLD.PHONE_NUMBER 		  
			, :OLD.EMAIL
            , :OLD.SSN_NUMBER
            , :OLD.MANAGER_ID
            , :NEW.EMPLOYEE_ID			  
			, :NEW.FIRST_NAME 			  
			, :NEW.MIDDLE_NAME 		  
			, :NEW.LAST_NAME 
            , :NEW.DATE_OF_BIRTH
			, :NEW.DEPARTMENT_ID 
            , :NEW.HIRE_DATE
			, :NEW.SALARY  
			, :NEW.PHONE_NUMBER 		  
			, :NEW.EMAIL
            , :NEW.SSN_NUMBER
            , :NEW.MANAGER_ID
			);
        
        -- deleting
        ELSE
			INSERT INTO employees_archive
		   (  EVENT_DATE	      
			, EVENT_TYPE          
			, USER_NAME           
			, OLD_EMPLOYEE_ID			  
			, OLD_FIRST_NAME 			  
			, OLD_MIDDLE_NAME 		  
			, OLD_LAST_NAME 
            , OLD_DATE_OF_BIRTH
			, OLD_DEPARTMENT_ID
            , OLD_HIRE_DATE
			, OLD_SALARY  
			, OLD_PHONE_NUMBER 		  
			, OLD_EMAIL
            , OLD_SSN_NUMBER
            , OLD_MANAGER_ID
            , NEW_EMPLOYEE_ID			  
			, NEW_FIRST_NAME 			  
			, NEW_MIDDLE_NAME 		  
			, NEW_LAST_NAME 
            , NEW_DATE_OF_BIRTH
			, NEW_DEPARTMENT_ID
            , NEW_HIRE_DATE
			, NEW_SALARY  
			, NEW_PHONE_NUMBER 		  
			, NEW_EMAIL
            , NEW_SSN_NUMBER
            , NEW_MANAGER_ID
			)
			VALUES
			(
			  SYSDATE
			, 'INSERT'
			, USER
			, :OLD.EMPLOYEE_ID			  
			, :OLD.FIRST_NAME 			  
			, :OLD.MIDDLE_NAME 		  
			, :OLD.LAST_NAME 
            , :OLD.DATE_OF_BIRTH
			, :OLD.DEPARTMENT_ID
            , :OLD.HIRE_DATE
			, :OLD.SALARY  
			, :OLD.PHONE_NUMBER 		  
			, :OLD.EMAIL
            , :OLD.SSN_NUMBER
            , :OLD.MANAGER_ID
			, NULL
			, NULL			  
			, NULL		  
			, NULL 		  
			, NULL 			  
			, NULL  
			, NULL		  
			, NULL
            , NULL
            , NULL
            , NULL
            , NULL
			);
        END IF;
	END;
    /
    
/*******************************************************************************
   Insert Rows
********************************************************************************/

SET DEFINE OFF;

ALTER TABLE employees DISABLE CONSTRAINT FK_DEPARTMENT_ID_TBL_EMPLOYEES;
ALTER TABLE departments DISABLE CONSTRAINT FK_MANAGER_ID_TBL_DEPARTMENTS;
ALTER TABLE product DISABLE CONSTRAINT FK_DISCOUNT_ID_TBL_PRODUCT;

-- departments table

Insert into DEPARTMENTS (DEPARTMENT_NAME,MANAGER_ID,DEPARTMENT_DESC) values ('Management','1','Supervision of other departments');
Insert into DEPARTMENTS (DEPARTMENT_NAME,MANAGER_ID,DEPARTMENT_DESC) values ('Development','2','Developing of the store''s website');
Insert into DEPARTMENTS (DEPARTMENT_NAME,MANAGER_ID,DEPARTMENT_DESC) values ('Purchase department','3','Management of assortment purchases and stock replenishment');
Insert into DEPARTMENTS (DEPARTMENT_NAME,MANAGER_ID,DEPARTMENT_DESC) values ('Sales department','4','Managing the sale of the assortment');

COMMIT; 

-- employees table

Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Kenon',null,'Andries',to_date('09/07/86 00:00:00','DD/MM/RR HH24:MI:SS'),'1',to_date('25/12/19 00:00:00','DD/MM/RR HH24:MI:SS'),'9300','279 266 4806','gandries0@google.de','779-22-3853',null);
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Brittney','Leonidas','Dimitriou',to_date('21/07/76 00:00:00','DD/MM/RR HH24:MI:SS'),'2',to_date('08/01/18 00:00:00','DD/MM/RR HH24:MI:SS'),'11800','604 235 4231','ldimitriou1@icio.us','825-48-6752','1');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Elwin',null,'Huckin',to_date('31/07/78 00:00:00','DD/MM/RR HH24:MI:SS'),'3',to_date('15/03/18 00:00:00','DD/MM/RR HH24:MI:SS'),'7400','997 567 5550','bhuckin2@thetimes.co.uk','797-73-9836','1');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Tierney','Elsinore','Powis',to_date('10/02/87 00:00:00','DD/MM/RR HH24:MI:SS'),'4',to_date('13/11/18 00:00:00','DD/MM/RR HH24:MI:SS'),'3700','911 733 7882','epowis3@4shared.com','857-99-2873','1');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Jone','Lew','Jirusek',to_date('03/11/75 00:00:00','DD/MM/RR HH24:MI:SS'),'2',to_date('04/08/18 00:00:00','DD/MM/RR HH24:MI:SS'),'7400','563 147 3132','ljirusek4@psu.edu','166-19-1878','2');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Clarine',null,'Calliss',to_date('10/09/91 00:00:00','DD/MM/RR HH24:MI:SS'),'2',to_date('30/03/20 00:00:00','DD/MM/RR HH24:MI:SS'),'4400','950 944 4973','mcalliss5@earthlink.net','520-28-8208','2');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Edvard',null,'Presho',to_date('18/08/88 00:00:00','DD/MM/RR HH24:MI:SS'),'3',to_date('18/12/21 00:00:00','DD/MM/RR HH24:MI:SS'),'5200','826 896 0204','hpresho6@nature.com','818-34-0837','3');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Dyan','Nico','Craxford',to_date('31/07/91 00:00:00','DD/MM/RR HH24:MI:SS'),'3',to_date('02/03/18 00:00:00','DD/MM/RR HH24:MI:SS'),'3700','749 923 0075','ncraxford7@cisco.com','622-33-9476','3');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Ansel','Gordan','Stanborough',to_date('15/10/88 00:00:00','DD/MM/RR HH24:MI:SS'),'4',to_date('20/04/19 00:00:00','DD/MM/RR HH24:MI:SS'),'11200','912 579 7826','gstanborough8@webs.com','810-49-5038','4');
Insert into  EMPLOYEES (FIRST_NAME,MIDDLE_NAME,LAST_NAME,DATE_OF_BIRTH,DEPARTMENT_ID,HIRE_DATE,SALARY,PHONE_NUMBER,EMAIL,SSN_NUMBER,MANAGER_ID) values ('Eileen','Farra','Sowerbutts',to_date('06/07/72 00:00:00','DD/MM/RR HH24:MI:SS'),'4',to_date('26/03/18 00:00:00','DD/MM/RR HH24:MI:SS'),'8300','119 228 0037','fsowerbutts9@illinois.edu','373-17-6842','4');

COMMIT;

-- addresses table

insert into addresses (line_1, line_2, city, zip_code, province, country) values ('18122 Helena Park', null, 'Philadelphia', '19125', 'Pennsylvania', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('60 Arizona Crossing', null, 'Salem', '97312', 'Oregon', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('3 Bayside Crossing', null, 'Falls Church', '22047', 'Virginia', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('915 Ryan Road', null, 'Salt Lake City', '84105', 'Utah', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('47 Jenifer Court', null, 'Shreveport', '71105', 'Louisiana', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('3864 Corscot Drive', null, 'Amarillo', '79171', 'Texas', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('1 Lindbergh Junction', null, 'Erie', '16565', 'Pennsylvania', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('18 Ruskin Hill', null, 'Columbus', '43210', 'Ohio', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('877 Springview Hill', null, 'Chicago', '60657', 'Illinois', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('517 Fairview Plaza', '7712', 'Lincoln', '68524', 'Nebraska', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('22 Rockefeller Parkway', null, 'Olympia', '98506', 'Washington', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('6418 Elgar Alley', '5', 'Tampa', '33647', 'Florida', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('17 Hanover Circle', null, 'Los Angeles', '90030', 'California', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('450 Magdeline Park', null, 'Newport Beach', '92662', 'California', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('37 Merry Way', null, 'Racine', '53405', 'Wisconsin', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('717 Northridge Center', null, 'Seminole', '34642', 'Florida', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('84013 North Place', '1230', 'New York City', '10110', 'New York', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('886 Becker Street', null, 'Brooklyn', '11205', 'New York', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('61 West Center', null, 'Lexington', '40591', 'Kentucky', 'United States');
insert into addresses (line_1, line_2, city, zip_code, province, country) values ('3 Sugar Avenue', null, 'Toledo', '43699', 'Ohio', 'United States');

COMMIT;

-- store_users table

Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Jody',null,'Cabell','256 375 7831','ccabell0@cbslocal.com','ccabell0','WEbtnzfbUDDW',to_timestamp('2019-08-15 17:25:56','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Obie','Kristina','Wyche','565 270 7798','kwyche1@un.org','kwyche1','sPSfFYsMRFsi',to_timestamp('2019-01-05 14:35:29','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Harland','Jeffie','Monaghan','303 296 7661','jmonaghan2@sciencedaily.com','jmonaghan2','7yhuPjF5ktJ',to_timestamp('2021-10-19 22:00:02','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Elisha',null,'Pelham','227 801 2408','epelham3@sfgate.com','hpelham3','sM3D0abL9Tp',to_timestamp('2021-03-06 02:21:18','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Ileane',null,'Dendle','563 933 9672','adendle4@nba.com','ldendle4','e2fEAnSW2q',to_timestamp('2020-10-19 22:41:07','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Jere',null,'McConville','976 967 1637','mmcconville5@usa.gov','jmcconville5','iYDgZSHWC3u',to_timestamp('2020-03-09 20:42:35','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Rosette',null,'Kelly','668 596 4040','mkelly6@drupal.org','skelly6','9Kab3oZWR',to_timestamp('2021-11-05 15:51:48','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Boone','Cornela','Kilby','354 862 1868','ckilby7@sitemeter.com','ckilby7','ipTiROqL',to_timestamp('2021-09-22 12:49:57','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Sara-ann','Bernadine','Brecon','414 469 2292','bbrecon8@ox.ac.uk','bbrecon8','rPbV7Qw',to_timestamp('2018-07-01 12:16:41','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Bartlett','Zahara','Menco','650 868 9081','zmenco9@friendfeed.com','zmenco9','IO2zZ8Q8',to_timestamp('2018-02-21 10:07:05','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Orly','Sayre','Bogeys','197 771 6322','sbogeysa@deviantart.com','sbogeysa','ZWrAsb',to_timestamp('2020-07-20 00:12:48','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Evonne','Othella','Warin','930 187 2285','owarinb@illinois.edu','owarinb','SHg9GN0ji',to_timestamp('2019-05-12 22:37:18','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Jaime','Engracia','Boles','756 463 9878','ebolesc@bandcamp.com','ebolesc','EYzbEd8CWxa',to_timestamp('2018-03-09 00:18:45','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Urson',null,'Keford','248 423 8798','rkefordd@ning.com','mkefordd','ybSzERUTi',to_timestamp('2021-11-06 22:53:08','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Cate','Alvy','Spreag','519 442 5275','aspreage@aboutads.info','aspreage','gVIu511G',to_timestamp('2021-11-25 14:57:08','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Cary','Geordie','Burborough','426 720 7069','gburboroughf@google.ru','gburboroughf','2MA7Y1t',to_timestamp('2021-11-25 06:54:20','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Arel',null,'Grinnikov','579 653 2134','ggrinnikovg@flickr.com','lgrinnikovg','sqoU66',to_timestamp('2021-04-22 09:47:00','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Helsa','Quincey','Saddleton','634 381 0198','qsaddletonh@ask.com','qsaddletonh','2XbBrzpWYMO',to_timestamp('2018-11-22 21:19:45','YYYY-MM-DD HH24:MI:SS'));
Insert into  STORE_USERS (FIRST_NAME,MIDDLE_NAME,LAST_NAME,PHONE_NUMBER,EMAIL,USERNAME,USER_PASSWORD,REGISTERED_AT) values ('Buiron','Melina','Wilds','121 459 7245','mwildsi@dagondesign.com','mwildsi','H9lKOFl4A',to_timestamp('2018-01-26 07:55:53','YYYY-MM-DD HH24:MI:SS'));

-- shopping_session table

Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('1',to_timestamp('2022-05-18 22:11:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-05-19 04:18:28,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('2',to_timestamp('2022-06-01 23:11:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-02 05:18:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('3',to_timestamp('2022-02-27 08:11:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-02-27 14:18:48,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('4',to_timestamp('2021-10-13 20:11:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-10-14 02:19:08,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('5',to_timestamp('2022-07-14 07:11:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-14 13:19:02,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('6',to_timestamp('2022-01-05 02:11:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-01-05 08:18:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('7',to_timestamp('2022-04-06 19:12:33,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-07 01:19:45,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('8',to_timestamp('2022-04-07 15:12:51,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-07 21:20:03,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('9',to_timestamp('2022-04-07 02:13:06,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-07 08:20:18,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('10',to_timestamp('2022-06-07 16:11:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-07 22:18:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('11',to_timestamp('2022-03-05 02:12:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-03-05 08:19:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('12',to_timestamp('2022-01-14 02:12:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-01-14 08:19:22,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('13',to_timestamp('2022-04-23 16:13:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-23 22:20:23,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('14',to_timestamp('2022-03-09 11:13:28,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-03-09 17:20:40,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('15',to_timestamp('2021-06-10 21:12:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-06-11 03:19:53,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('16',to_timestamp('2022-07-04 21:13:19,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-05 03:20:31,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('17',to_timestamp('2021-11-05 08:12:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-11-05 14:19:38,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('18',to_timestamp('2022-02-28 10:13:37,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-02-28 16:20:49,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  SHOPPING_SESSION (USER_ID,CREATED_AT,MODIFIED_AT) values ('19',to_timestamp('2022-04-19 18:12:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-20 00:19:27,000000000','YYYY-MM-DD HH24:MI:SSXFF'));

COMMIT;

-- product_categories table

insert into product_categories values (1, 'Computers, Laptops and Consoles');
insert into product_categories values (2, 'TV and Video');
insert into product_categories values (3, 'Headphones and Speakers');
insert into product_categories values (4, 'Smartphones and Smartwatches');
insert into product_categories values (5, 'Monitors');
insert into product_categories values (6, 'Computer parts');
insert into product_categories values (7, 'Keyboard and mouse');
insert into product_categories values (8, 'AGD');

-- discount table

Insert into  DISCOUNT (DISCOUNT_ID,DISCOUNT_NAME,DISCOUNT_DESC,DISCOUNT_PERCENT,IS_ACTIVE_STATUS,CREATED_AT,MODIFIED_AT) values ('1','Hits of the Week','Weekly discount','15','Y',to_timestamp('2022-03-10 02:27:51','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  DISCOUNT (DISCOUNT_ID,DISCOUNT_NAME,DISCOUNT_DESC,DISCOUNT_PERCENT,IS_ACTIVE_STATUS,CREATED_AT,MODIFIED_AT) values ('2','Summer Sales',null,'30','Y',to_timestamp('2022-06-10 02:28:08','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  DISCOUNT (DISCOUNT_ID,DISCOUNT_NAME,DISCOUNT_DESC,DISCOUNT_PERCENT,IS_ACTIVE_STATUS,CREATED_AT,MODIFIED_AT) values ('3','Hot Promotions',null,'25','Y',to_timestamp('2022-06-01 02:27:56','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-07-14 02:28:38','YYYY-MM-DD HH24:MI:SS'));
Insert into  DISCOUNT (DISCOUNT_ID,DISCOUNT_NAME,DISCOUNT_DESC,DISCOUNT_PERCENT,IS_ACTIVE_STATUS,CREATED_AT,MODIFIED_AT) values ('4','Black Friday',null,'40','N',to_timestamp('2022-02-15 02:28:13','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  DISCOUNT (DISCOUNT_ID,DISCOUNT_NAME,DISCOUNT_DESC,DISCOUNT_PERCENT,IS_ACTIVE_STATUS,CREATED_AT,MODIFIED_AT) values ('5','Holiday Sales',null,'35','N',to_timestamp('2021-12-14 02:28:18','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-01-01 16:28:24','YYYY-MM-DD HH24:MI:SS'));

-- products table 

Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('ASUS X515-BQ26W 8GB RAM 256GB SSD','1','HR278YRE','2399','1',to_timestamp('2022-07-01 09:57:48','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-07-12 23:58:55','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('TV Samsung UE65A DVB','2','MN621DFV','2449',null,to_timestamp('2022-07-06 13:03:49','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-07-13 00:00:01','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('JBL Quantum 600','3','YT008BVG','399','3',to_timestamp('2022-07-11 10:54:59','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-07-13 00:05:09','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('realme 8 4+64','4','PQ613BSD','839',null,to_timestamp('2022-03-15 04:12:03','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Samsung Galaxy A52','4','TR849PQE','1199','1',to_timestamp('2022-05-09 13:13:07','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Xiaomi Redmi Buds 3 Lite','3','UT432PQE','86',null,to_timestamp('2021-12-23 00:14:07','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-05-25 00:14:12','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Samsung RS65 Fridge','8','UT043LSD','5999',null,to_timestamp('2022-01-24 09:15:27','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Apple Iphone 11','4','NB923PQO','2499','3',to_timestamp('2021-11-23 00:16:10','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Logitech MK220','7','UY840PDN','90',null,to_timestamp('2022-01-12 00:17:42','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Sharp 50BL5','2','FD947OGJ','1490','4',to_timestamp('2021-12-20 10:18:40','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Asus Vivobook Pro 14','1','3T34RPO2','5299',null,to_timestamp('2022-01-01 00:19:36','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-04-28 22:19:42','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('AOC 23PRO4','5','YE04PRGS','1500','2',to_timestamp('2022-07-11 00:20:58','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Gigabyte GTX 2080Ti ','6','3T04T843','2299',null,to_timestamp('2021-10-06 00:21:54','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Acer Aspire TX Turbo 2','1','DV932MNN','1999','1',to_timestamp('2022-01-13 11:24:26','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Krups Evidence EA20','8','AS64Y91M','1800','5',to_timestamp('2021-12-08 00:25:47','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-02-14 00:25:52','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Apple Iphone 12 mini','4','RT472POS','3599','2',to_timestamp('2022-01-12 00:26:49','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Audio-Technica ATC900','3','YRP23LLL','499','2',to_timestamp('2022-04-26 00:27:56','YYYY-MM-DD HH24:MI:SS'),to_timestamp('2022-05-19 00:28:00','YYYY-MM-DD HH24:MI:SS'));
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('iRobot Rumba J7+','8','RE056PLF','3299',null,to_timestamp('2022-03-14 14:29:07','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('Xbox Series X + Halo Infinite','1','EPROL23S','2697','1',to_timestamp('2022-07-04 20:30:16','YYYY-MM-DD HH24:MI:SS'),null);
Insert into  PRODUCT (PRODUCT_NAME,CATEGORY_ID,SKU,PRICE,DISCOUNT_ID,CREATED_AT,LAST_MODIFIED) values ('BenQ GW2283','5','EPPLS001','579',null,to_timestamp('2022-03-05 00:31:10','YYYY-MM-DD HH24:MI:SS'),null);

COMMIT;

ALTER TABLE employees ENABLE CONSTRAINT FK_DEPARTMENT_ID_TBL_EMPLOYEES;
ALTER TABLE departments ENABLE CONSTRAINT FK_MANAGER_ID_TBL_DEPARTMENTS;
ALTER TABLE product ENABLE CONSTRAINT FK_DISCOUNT_ID_TBL_PRODUCT;

-- order_details table

ALTER TABLE order_details DISABLE CONSTRAINT FK_PAYMENT_ID_TBL_ORDER_DETAILS;

Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('1','575','1','Inpost','12',to_timestamp('2022-05-18 23:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('6','5299','2','Inpost','19',to_timestamp('2022-01-05 03:29:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('10','2898','3','DPD','18',to_timestamp('2022-06-07 17:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('3','1576','4','UPS','17',to_timestamp('2022-02-27 09:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('2','3028','5','DPD','16',to_timestamp('2022-06-02 00:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('5','90','6','DPD','1',to_timestamp('2022-07-14 08:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-15 23:31:47,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('4','4498','7','UPS','2',to_timestamp('2021-10-13 21:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('11','5498','8','DHL','3',to_timestamp('2022-03-05 03:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('12','2449','9','Inpost','4',to_timestamp('2022-01-14 03:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('19','2697','10','DHL','5',to_timestamp('2022-04-19 19:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('17','17046','11','DHL','6',to_timestamp('2021-11-05 09:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('7','399','12','Inpost','15',to_timestamp('2022-04-06 20:30:33,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-07 23:32:01,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('15','2697','13','DPD','14',to_timestamp('2021-06-10 22:30:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('8','579','14','DPD','13',to_timestamp('2022-04-07 16:30:51,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('9','1490','15','Inpost','7',to_timestamp('2022-04-07 03:31:06,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('13','1414','16','DPD','8',to_timestamp('2022-04-23 17:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('16','1800','17','Inpost','9',to_timestamp('2022-07-04 22:31:19,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-05 03:32:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('14','1800','18','DHL','10',to_timestamp('2022-03-09 12:31:28,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_DETAILS (USER_ID,TOTAL,PAYMENT_ID,SHIPPING_METHOD,DELIVERY_ADRESS_ID,CREATED_AT,MODIFIED_AT) values ('18','4598','19','UPS','11',to_timestamp('2022-02-28 11:31:37,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);

COMMIT;

-- payment_details table

Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('1','575','PayPal','PROCESSED',to_timestamp('2022-05-19 23:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('2','5299','WildApricot Payments','PROCESSED',to_timestamp('2022-01-06 03:29:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('3','2898','WildApricot Payments','PROCESSED',to_timestamp('2022-06-08 17:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('4','1576','PayPal','PROCESSED',to_timestamp('2022-02-28 09:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('5','3028','Stripe','PROCESSED',to_timestamp('2022-06-03 00:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('6','90','PayPal','PENDING',to_timestamp('2022-07-15 08:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-16 18:02:43,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('7','4498','PayPal','PROCESSED',to_timestamp('2021-10-14 21:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('8','5498','WildApricot Payments','FAILURE',to_timestamp('2022-03-06 03:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-04 18:02:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('9','2449','PayPal','PROCESSED',to_timestamp('2022-01-15 03:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('10','2697','PayPal','PROCESSED',to_timestamp('2022-04-20 19:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('11','17046','Bank of America','PROCESSED',to_timestamp('2021-11-06 09:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('12','399','PayPal','PROCESSED',to_timestamp('2022-04-07 20:30:33,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('13','2697','Stripe','PROCESSED',to_timestamp('2021-06-11 22:30:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('14','579','WildApricot Payments','PROCESSED',to_timestamp('2022-04-08 16:30:51,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('15','1490','PayPal','PROCESSED',to_timestamp('2022-04-08 03:31:06,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('16','1414','Bank of America','PROCESSED',to_timestamp('2022-04-24 17:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('17','1800','PayPal','PENDING',to_timestamp('2022-07-05 22:31:19,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-07-06 18:02:33,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('18','1800','Stripe','PROCESSED',to_timestamp('2022-03-10 12:31:28,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  PAYMENT_DETAILS (ORDER_ID,AMOUNT,PROVIDER,PAYMENT_STATUS,CREATED_AT,MODIFIED_AT) values ('19','4598','WildApricot Payments','FAILURE',to_timestamp('2022-03-01 11:31:37,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);

COMMIT;

-- order_items table

Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('1','3',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('1','6',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('1','9',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-05-20 01:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('2','11',to_timestamp('2022-01-05 15:29:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('3','17',to_timestamp('2022-06-08 05:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('3','1',to_timestamp('2022-06-08 05:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-08 19:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('4','10',to_timestamp('2022-02-27 21:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('4','6',to_timestamp('2022-02-27 21:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('5','20',to_timestamp('2022-06-02 12:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-03 02:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('5','2',to_timestamp('2022-06-02 12:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('6','9',to_timestamp('2022-07-14 20:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('7','5',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-10-14 23:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('7','18',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('8','16',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('8','3',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('8','12',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('9','2',to_timestamp('2022-01-14 15:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('10','19',to_timestamp('2022-04-20 07:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-20 21:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('11','7',to_timestamp('2021-11-05 21:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('11','18',to_timestamp('2021-11-05 21:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('11','11',to_timestamp('2021-11-05 21:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-11-06 11:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('11','2',to_timestamp('2021-11-05 21:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('12','3',to_timestamp('2022-04-07 08:30:33,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('13','19',to_timestamp('2021-06-11 10:30:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-06-12 00:30:41,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('14','20',to_timestamp('2022-04-08 04:30:51,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('15','10',to_timestamp('2022-04-07 15:31:06,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('16','3',to_timestamp('2022-04-24 05:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-24 19:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('16','9',to_timestamp('2022-04-24 05:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('16','6',to_timestamp('2022-04-24 05:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('16','4',to_timestamp('2022-04-24 05:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-24 19:31:11,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('17','15',to_timestamp('2022-07-05 10:31:19,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('18','15',to_timestamp('2022-03-10 00:31:28,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('19','13',to_timestamp('2022-02-28 23:31:37,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  ORDER_ITEMS (ORDER_DETAILS_ID,PRODUCT_ID,CREATED_AT,MODIFIED_AT) values ('19','13',to_timestamp('2022-02-28 23:31:37,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);

COMMIT;

-- cart_item table

Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('1','3','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('1','6','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('1','9','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('2','20','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('2','2','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('3','10','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-05-20 01:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('3','6','1',to_timestamp('2022-05-19 11:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-05-20 01:29:16,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('4','5','1',to_timestamp('2022-01-05 15:29:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('4','18','1',to_timestamp('2022-01-05 15:29:24,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('5','9','1',to_timestamp('2022-06-08 05:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('6','11','1',to_timestamp('2022-06-08 05:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-08 19:29:29,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('7','3','1',to_timestamp('2022-02-27 21:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('8','20','1',to_timestamp('2022-02-27 21:29:36,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('9','10','1',to_timestamp('2022-06-02 12:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-06-03 02:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('10','17','1',to_timestamp('2022-06-02 12:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('11','16','1',to_timestamp('2022-07-14 20:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('11','3','1',to_timestamp('2022-07-14 20:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('11','12','1',to_timestamp('2022-07-14 20:29:50,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('12','2','1',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2021-10-14 23:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('13','3','1',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('13','9','1',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('13','6','1',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('13','4','1',to_timestamp('2021-10-14 09:29:56,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('14','15','1',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('15','19','1',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('16','15','1',to_timestamp('2022-03-05 15:30:04,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('17','7','1',to_timestamp('2022-01-14 15:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('17','18','1',to_timestamp('2022-01-14 15:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('18','13','2',to_timestamp('2022-04-20 07:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'),to_timestamp('2022-04-20 21:30:15,000000000','YYYY-MM-DD HH24:MI:SSXFF'));
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('19','19','1',to_timestamp('2021-11-05 21:30:26,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('10','1','1',to_timestamp('2022-06-02 12:29:44,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('17','11','1',to_timestamp('2022-01-14 15:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);
Insert into  CART_ITEM (SESSION_ID,PRODUCT_ID,QUANTITY,CREATED_AT,MODIFIED_AT) values ('17','2','1',to_timestamp('2022-01-14 15:30:10,000000000','YYYY-MM-DD HH24:MI:SSXFF'),null);


ALTER TABLE order_details ENABLE CONSTRAINT FK_PAYMENT_ID_TBL_ORDER_DETAILS;

-- stock table

Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('1','47','120','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('2','21','60','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('3','321','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('4','121','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('5','169','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('6','618','1200','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('7','24','30','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('8','273','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('9','771','1200','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('10','60','120','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('11','7','40','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('12','25','60','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('13','16','40','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('14','59','60','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('15','31','100','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('16','199','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('17','29','400','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('18','75','80','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('19','499','1000','1PCS');
Insert into  STOCK (PRODUCT_ID,QUANTITY,MAX_STOCK_QUANTITY,UNIT) values ('20','1','80','1PCS');

COMMIT;
    
    

