BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "price_observation" (
    "id" bigserial PRIMARY KEY,
    "queryKey" text NOT NULL,
    "observationKey" text NOT NULL,
    "platform" text NOT NULL,
    "productId" text NOT NULL,
    "sourceUrl" text NOT NULL,
    "seller" text NOT NULL,
    "priceCents" bigint NOT NULL,
    "priceText" text NOT NULL,
    "observedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "price_observation_unique_idx" ON "price_observation" USING btree ("observationKey");
CREATE INDEX "price_observation_query_time_idx" ON "price_observation" USING btree ("queryKey", "observedAt");


--
-- MIGRATION VERSION FOR goods_search
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('goods_search', '20261117145332670', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261117145332670', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
