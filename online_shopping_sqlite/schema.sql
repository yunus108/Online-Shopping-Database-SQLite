-- Represent sellers in the site
CREATE TABLE IF NOT EXISTS "seller_accounts" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "e-mail" TEXT UNIQUE NOT NULL CHECK("e-mail" LIKE '%@%'),
    "password" TEXT NOT NULL CHECK(LENGTH("password") >= 8), 
    "age" INTEGER NOT NULL CHECK("age" >= 18),
    "country" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "deleted" INTEGER NOT NULL DEFAULT 0 CHECK("deleted" = 0 OR "deleted" = 1),
    PRIMARY KEY("id")
);

-- Represent products in the site
CREATE TABLE IF NOT EXISTS "products" (
    "id" INTEGER,
    "seller_id" INTEGER,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "subcategory" TEXT,
    "description" TEXT NOT NULL,
    "price_$" REAL NOT NULL,
    "rating" REAL NOT NULL DEFAULT 0.0,
    PRIMARY KEY("id"),
    FOREIGN KEY("seller_id") REFERENCES "seller_accounts"("id")
);
    
-- Represent buyers in the site
CREATE TABLE IF NOT EXISTS "buyer_accounts" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "e-mail" TEXT UNIQUE NOT NULL CHECK("e-mail" LIKE '%@%'),
    "password" TEXT NOT NULL CHECK(LENGTH("password") >= 8),
    "age" INTEGER NOT NULL CHECK("age" >= 18),
    "country" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "deleted" INTEGER NOT NULL DEFAULT 0 CHECK("deleted" = 0 OR "deleted" = 1),
    PRIMARY KEY("id")
);

-- Represent individual transactions in the site
CREATE TABLE IF NOT EXISTS "transactions" (
    "id" INTEGER,
    "seller_id" INTEGER,
    "product_id" INTEGER,
    "buyer_id" INTEGER,
    "date_time" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("seller_id") REFERENCES "seller_accounts"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("buyer_id") REFERENCES "buyer_accounts"("id")
);

-- Represent individual given ratings in the site
CREATE TABLE IF NOT EXISTS "ratings" (
    "id" INTEGER,
    "seller_id" INTEGER,
    "product_id" INTEGER,
    "buyer_id" INTEGER,
    "given_rating" REAL NOT NULL CHECK("given_rating" BETWEEN 1.0 AND 5.0),
    PRIMARY KEY("id"),
    FOREIGN KEY("seller_id") REFERENCES "seller_accounts"("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id"),
    FOREIGN KEY("buyer_id") REFERENCES "buyer_accounts"("id")
);

-- Create trigger to update the "rating" column in the "products" table each time an insertion occurs on "ratings" table
CREATE TRIGGER IF NOT EXISTS "rating_update"
AFTER INSERT ON "ratings"
FOR EACH ROW 
BEGIN
UPDATE "products" SET "rating" = (
    SELECT ROUND(AVG("given_rating"),1) FROM "ratings" WHERE "product_id" = NEW."product_id"
) WHERE "id" = NEW."product_id";
END;

-- Create view to list top 100 sellers by the amount of products they have sold while anonymising their last names
CREATE VIEW IF NOT EXISTS "top_dealers" AS
SELECT "first_name", 'Anonymous' AS "last_name", "age", "country" FROM "seller_accounts" WHERE "id" IN (
    SELECT "seller_id" FROM "transactions" GROUP BY "seller_id" 
    ORDER BY COUNT("product_id") DESC LIMIT 100
);

-- Create view to list top 100 products by the total amount of income they have generated and the total amount of income for each product
CREATE VIEW IF NOT EXISTS "top_earning_products" AS
SELECT "products"."id", COUNT("transactions"."id") * "price_$" AS "money_earned" FROM "products" 
JOIN "transactions" ON "products"."id" = "transactions"."product_id"
GROUP BY "product_id" ORDER BY "money_earned" DESC LIMIT 100;

-- Create indexes to speed common searches
CREATE INDEX IF NOT EXISTS "product_search" ON "products"("name", "category", "subcategory");
CREATE INDEX IF NOT EXISTS "seller_email_search" ON "seller_accounts"("e-mail");
CREATE INDEX IF NOT EXISTS "buyer_email_search" ON "buyer_accounts"("e-mail");

