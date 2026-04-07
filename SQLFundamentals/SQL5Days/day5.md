# Day 5: NoSQL & Cloud Databases (Azure SQL)

---

## Table of Contents

1. [Recap & Context](#1-recap--context)
2. [Brief History of NoSQL Databases](#2-brief-history-of-nosql-databases)
3. [NoSQL Database Features](#3-nosql-database-features)
4. [NoSQL Database Types](#4-nosql-database-types)
5. [Document Databases (Deep Dive)](#5-document-databases-deep-dive)
6. [Key-Value Stores](#6-key-value-stores)
7. [Column-Family Databases](#7-column-family-databases)
8. [Graph Databases](#8-graph-databases)
9. [RDBMS vs NoSQL — Detailed Comparison](#9-rdbms-vs-nosql--detailed-comparison)
10. [When and Why to Use NoSQL](#10-when-and-why-to-use-nosql)
11. [NoSQL Demo — Basic CRUD Operations](#11-nosql-demo--basic-crud-operations)
12. [Introduction to Cloud Databases](#12-introduction-to-cloud-databases)
13. [Introduction to Azure SQL Database](#13-introduction-to-azure-sql-database)
14. [Demo: Creating and Managing Azure SQL Database](#14-demo-creating-and-managing-azure-sql-database)
15. [Azure SQL vs On-Premises SQL Server](#15-azure-sql-vs-on-premises-sql-server)
16. [Other Azure Data Services](#16-other-azure-data-services)
17. [5-Day Course Review](#17-5-day-course-review)
18. [Day 5 Summary](#18-day-5-summary)
19. [Hands-On Exercises](#19-hands-on-exercises)
20. [Next Steps & Resources](#20-next-steps--resources)

---

## 1. Recap & Context

### 1.1 Quick Recap of Day 4

| Concept                | Key Point                                             |
| ---------------------- | ----------------------------------------------------- |
| Clustered Index        | Physical sort order; one per table                    |
| Non-Clustered Index    | Separate lookup structure; many per table              |
| Covering Index         | INCLUDE columns to avoid Key Lookups                  |
| Views                  | Virtual tables; simplify, secure, and reuse queries   |
| Stored Procedures      | Reusable T-SQL programs with parameters               |
| TRY-CATCH              | Structured error handling; THROW to re-raise           |
| Functions              | Scalar (single value) or Table-Valued (iTVF preferred) |
| Triggers               | Auto-fire on DML events; use sparingly                 |

### 1.2 What We've Learned So Far

```
Day 1: Foundations      → RDBMS, tables, data types, DDL/DML/DCL, constraints
Day 2: Core SQL         → Functions, GROUP BY, HAVING, MERGE, set operators
Day 3: Data Retrieval   → Joins, subqueries, CTEs, optimization basics
Day 4: Database Objects → Indexes, views, stored procedures, TRY-CATCH
Day 5: Beyond RDBMS     → NoSQL, cloud databases, Azure SQL ← YOU ARE HERE
```

### 1.3 Why Day 5 Matters

The world of databases has expanded far beyond relational systems. Modern
applications often use a **polyglot persistence** approach — combining multiple
database technologies to leverage each one's strengths.

```
Traditional:
  Application → Single RDBMS (SQL Server)

Modern (Polyglot):
  Application → SQL Server (transactions, reporting)
              → Redis (caching, sessions)
              → MongoDB (content management)
              → Neo4j (social graphs, recommendations)
              → Azure Cosmos DB (global distribution)
```

---

## 2. Brief History of NoSQL Databases

### 2.1 Timeline

| Year      | Event                                                          |
| --------- | -------------------------------------------------------------- |
| 1970      | E. F. Codd publishes the relational model                     |
| 1970–2000 | RDBMS dominates: Oracle, SQL Server, MySQL, PostgreSQL         |
| 1998      | Carlo Strozzi coins "NoSQL" (a lightweight relational DB)      |
| 2004      | Google publishes the **BigTable** paper                        |
| 2006      | Amazon publishes the **Dynamo** paper                          |
| 2007      | MongoDB development begins                                     |
| 2008      | Facebook open-sources **Cassandra**                            |
| 2009      | The term "NoSQL" is reintroduced at a meetup in San Francisco  |
| 2010      | Redis gains popularity for caching                             |
| 2012      | Neo4j popularizes graph databases                              |
| 2017      | Azure Cosmos DB launches (multi-model)                         |
| 2020s     | NewSQL emerges (CockroachDB, Google Spanner)                   |

### 2.2 What Drove the NoSQL Movement?

The rise of **Web 2.0** brought challenges that traditional RDBMS struggled with:

```
Problem 1: MASSIVE SCALE
  Facebook: billions of posts, likes, comments
  Google:   billions of web pages to index
  Amazon:   millions of transactions per day
  → RDBMS vertical scaling (bigger server) hit physical limits

Problem 2: FLEXIBLE DATA
  User profiles with varying fields
  Social media posts with different media types
  IoT sensor data with changing schemas
  → Rigid table schemas slowed development

Problem 3: GLOBAL DISTRIBUTION
  Users worldwide need low-latency access
  Data must be replicated across continents
  → RDBMS was designed for single-server or limited distribution

Problem 4: DEVELOPMENT SPEED
  Agile teams shipping features daily
  Schema changes in RDBMS require migrations
  → NoSQL's flexible schemas enabled faster iteration
```

### 2.3 What Does "NoSQL" Actually Mean?

The term has evolved over time:

```
Original meaning:  "No SQL"      → databases that don't use SQL at all
Modern meaning:    "Not Only SQL" → SQL is great, but it's not the only option
```

NoSQL is an umbrella term for any database that is **not a traditional
relational database**. NoSQL databases may or may not support SQL-like
query languages.

---

## 3. NoSQL Database Features

### 3.1 Core Characteristics

| Feature               | RDBMS                       | NoSQL                          |
| --------------------- | --------------------------- | ------------------------------ |
| **Schema**            | Fixed (tables, columns)     | Flexible / schema-less         |
| **Scaling**           | Vertical (scale up)         | Horizontal (scale out)         |
| **Data Model**        | Tables with rows/columns    | Documents, key-value, graphs…  |
| **Transactions**      | Full ACID                   | Varies (eventual consistency)  |
| **Query Language**    | SQL (standardized)          | Database-specific APIs         |
| **Relationships**     | JOINs between tables        | Embedded/nested data           |
| **Best For**          | Structured, relational data | Unstructured, high-volume data |

### 3.2 The CAP Theorem

The **CAP theorem** (Brewer's theorem) states that a distributed system can
guarantee only **two out of three** properties simultaneously:

```
        Consistency (C)
           /\
          /  \
         /    \
        /  CA  \         CP: Consistent + Partition-tolerant
       /________\            (e.g., traditional RDBMS, HBase)
      /\        /\
     /  \  CP  /  \      CA: Consistent + Available
    / AP \    /    \         (e.g., single-node RDBMS — not distributed)
   /______\  /______\
Availability (A)   Partition
                   Tolerance (P)

AP: Available + Partition-tolerant
    (e.g., Cassandra, DynamoDB, CouchDB)
```

| Property               | Meaning                                              |
| ---------------------- | ---------------------------------------------------- |
| **Consistency**        | Every read gets the most recent write                |
| **Availability**       | Every request gets a response (even if not latest)   |
| **Partition Tolerance**| System works despite network failures between nodes  |

> **In practice:** Distributed databases must be partition-tolerant (P), so
> the real trade-off is between **Consistency (CP)** and **Availability (AP)**.

### 3.3 ACID vs BASE

| Property   | ACID (RDBMS)                    | BASE (NoSQL)                          |
| ---------- | ------------------------------- | ------------------------------------- |
| **A**      | Atomicity                       | **B**asically **A**vailable            |
| **C**      | Consistency                     | **S**oft state                         |
| **I**      | Isolation                       | **E**ventual consistency               |
| **D**      | Durability                      |                                        |

```
ACID: "After a transaction, the data is GUARANTEED to be correct."
BASE: "The data will EVENTUALLY be correct, but there may be brief periods
       where different nodes have different values."
```

**Example: Social Media "Like" Count**

```
ACID approach (RDBMS):
  User clicks "Like" → Transaction locks the row → Updates count → Unlocks
  Every reader sees the exact current count
  Slower under heavy load

BASE approach (NoSQL):
  User clicks "Like" → Write accepted on nearest node → Propagates to others
  For a few seconds, different users might see 999 or 1001 likes
  Eventually all nodes agree on 1000
  Much faster at scale
```

### 3.4 Horizontal vs Vertical Scaling

```
Vertical Scaling (Scale UP):                Horizontal Scaling (Scale OUT):
┌──────────────────────┐                    ┌────────┐ ┌────────┐ ┌────────┐
│                      │                    │ Node 1 │ │ Node 2 │ │ Node 3 │
│   BIGGER SERVER      │                    │ ┌────┐ │ │ ┌────┐ │ │ ┌────┐ │
│   ┌────────────────┐ │                    │ │Data│ │ │ │Data│ │ │ │Data│ │
│   │ More CPU       │ │                    │ │ A  │ │ │ │ B  │ │ │ │ C  │ │
│   │ More RAM       │ │                    │ └────┘ │ │ └────┘ │ │ └────┘ │
│   │ More Storage   │ │                    └────────┘ └────────┘ └────────┘
│   │ More $$$       │ │                         ↕          ↕          ↕
│   └────────────────┘ │                    ┌────────┐ ┌────────┐ ┌────────┐
│                      │                    │ Node 4 │ │ Node 5 │ │ Node 6 │
│  Has physical limits │                    └────────┘ └────────┘ └────────┘
└──────────────────────┘                    Add more commodity servers as needed

RDBMS: typically vertical                   NoSQL: designed for horizontal
(though modern RDBMS can                    (data automatically distributed
 do some horizontal scaling)                 across nodes — "sharding")
```

---

## 4. NoSQL Database Types

### 4.1 The Four Main Categories

```
┌─────────────────────────────────────────────────────────────────┐
│                    NoSQL Database Types                          │
├────────────────┬───────────────┬──────────────┬────────────────┤
│   Document     │  Key-Value    │ Column-Family│    Graph       │
│                │               │              │                │
│  { JSON docs } │  key → value  │  wide rows   │  nodes & edges │
│                │               │              │                │
│  MongoDB       │  Redis        │  Cassandra   │  Neo4j         │
│  CouchDB       │  DynamoDB     │  HBase       │  Amazon Neptune│
│  Cosmos DB     │  Memcached    │  ScyllaDB    │  ArangoDB      │
│  Firestore     │  Cosmos DB    │  Cosmos DB   │  Cosmos DB     │
└────────────────┴───────────────┴──────────────┴────────────────┘
```

### 4.2 Quick Comparison

| Type          | Data Model        | Best For                        | Query Pattern        |
| ------------- | ----------------- | ------------------------------- | -------------------- |
| **Document**  | JSON/BSON docs    | Content mgmt, catalogs, apps    | Flexible queries     |
| **Key-Value** | Simple key→value  | Caching, sessions, preferences  | Get/Set by key       |
| **Column**    | Column families   | Time-series, analytics, IoT     | Read/write by column |
| **Graph**     | Nodes + edges     | Social networks, recommendations| Traverse relationships|

---

## 5. Document Databases (Deep Dive)

### 5.1 How Document Databases Work

Data is stored as **documents** — typically JSON or BSON (Binary JSON). Each
document is a self-contained unit with all its related data.

### 5.2 RDBMS vs Document Model

```
RDBMS Approach (3 tables, normalized):

Students table:                 Enrollments table:         Courses table:
┌────┬───────┬─────────┐       ┌────┬────┬────┬─────┐     ┌────┬─────────┐
│ ID │ Name  │ Email   │       │ ID │ SID│ CID│Grade│     │ ID ��� Name    │
├────┼───────┼─────────┤       ├────┼────┼────┼─────┤     ├────┼─────────┤
│ 1  │ Alice │ a@e.com │       │ 1  │ 1  │ 10 │ 92  │     │ 10 │ Math    │
│ 2  │ Bob   │ b@e.com │       │ 2  │ 1  │ 20 │ 85  │     │ 20 │ Science │
└────┴───────┴─────────┘       │ 3  │ 2  │ 10 │ 78  │     └────┴─────────┘
                                └────┴────┴────┴─────┘
Need JOINs to get a student's full information.

Document Approach (single collection, denormalized):

{
  "_id": 1,
  "name": "Alice",
  "email": "a@e.com",
  "enrollments": [
    { "course": "Math",    "grade": 92 },
    { "course": "Science", "grade": 85 }
  ]
}

{
  "_id": 2,
  "name": "Bob",
  "email": "b@e.com",
  "enrollments": [
    { "course": "Math", "grade": 78 }
  ]
}

All data for one student is in ONE document — no JOINs needed!
```

### 5.3 Document Structure

```json
{
  "_id": "prod_001",
  "name": "Laptop Pro 15",
  "category": "Electronics",
  "price": 1299.99,
  "stock": 50,
  "specifications": {
    "cpu": "Intel Core i7",
    "ram": "16GB",
    "storage": "512GB SSD",
    "display": "15.6 inch FHD"
  },
  "tags": ["laptop", "computer", "electronics", "portable"],
  "reviews": [
    {
      "user": "Alice",
      "rating": 5,
      "comment": "Excellent performance!",
      "date": "2025-02-15"
    },
    {
      "user": "Bob",
      "rating": 4,
      "comment": "Good but a bit heavy.",
      "date": "2025-03-01"
    }
  ],
  "isActive": true,
  "createdAt": "2025-01-10T08:30:00Z"
}
```

Key observations:
- **Nested objects** (`specifications`) — no need for a separate table.
- **Arrays** (`tags`, `reviews`) — one-to-many relationships embedded.
- **Flexible schema** — different products can have different fields.

### 5.4 Schema Flexibility

```json
// Electronics product — has specifications
{
  "_id": "prod_001",
  "name": "Laptop Pro 15",
  "category": "Electronics",
  "specifications": { "cpu": "i7", "ram": "16GB" }
}

// Clothing product — has sizes instead of specifications
{
  "_id": "prod_006",
  "name": "Cotton T-Shirt",
  "category": "Clothing",
  "sizes": ["XS", "S", "M", "L", "XL"],
  "material": "100% Cotton"
}

// Book — has author and ISBN instead
{
  "_id": "prod_010",
  "name": "SQL in 24 Hours",
  "category": "Books",
  "author": "Ryan Stephens",
  "isbn": "978-0672337598",
  "pages": 600
}

// All three documents can live in the SAME collection!
// No ALTER TABLE needed when adding new product types.
```

### 5.5 Popular Document Databases

| Database          | Developer   | Key Features                              |
| ----------------- | ----------- | ----------------------------------------- |
| **MongoDB**       | MongoDB Inc | Most popular document DB, BSON, aggregation pipeline |
| **CouchDB**       | Apache      | HTTP/REST API, master-master replication   |
| **Cosmos DB**     | Microsoft   | Multi-model, global distribution, SLAs     |
| **Firestore**     | Google      | Real-time sync, mobile-first              |
| **DynamoDB**      | Amazon      | Key-value + document, serverless           |

---

## 6. Key-Value Stores

### 6.1 How Key-Value Stores Work

The simplest NoSQL model — every piece of data is stored as a **key-value pair**.

```
┌─────────────────┬─────────────────────────────────────┐
│      Key        │              Value                   │
├─────────────────┼─────────────────────────────────────┤
│ user:1001       │ {"name":"Alice","email":"a@e.com"}  │
│ session:abc123  │ {"userId":1001,"expires":"2025-04"} │
│ cart:1001       │ [{"productId":1,"qty":2}]           │
│ config:theme    │ "dark"                              │
│ counter:visits  │ 428573                              │
└─────────────────┴─────────────────────────────────────┘
```

### 6.2 Operations

```
GET    key          → returns value
SET    key value    → stores value
DELETE key          → removes key-value pair
EXISTS key          → checks if key exists
EXPIRE key seconds  → sets a time-to-live (TTL)
INCR   key          → atomically increments a numeric value
```

### 6.3 Key-Value Use Cases

| Use Case              | Why Key-Value?                                  |
| --------------------- | ----------------------------------------------- |
| **Caching**           | Extremely fast reads (in-memory)                |
| **Session Management**| Store user sessions with TTL                    |
| **Shopping Carts**    | Temporary data, keyed by user                   |
| **Rate Limiting**     | Track request counts with expiry                |
| **Feature Flags**     | Quick lookups by flag name                      |
| **Leaderboards**      | Sorted sets with scores                         |

### 6.4 Popular Key-Value Databases

| Database       | Key Feature                                          |
| -------------- | ---------------------------------------------------- |
| **Redis**      | In-memory, rich data structures, pub/sub, scripting  |
| **Memcached**  | In-memory, simple, distributed caching               |
| **DynamoDB**   | Managed, serverless, key-value + document            |
| **etcd**       | Distributed config store (used by Kubernetes)        |
| **Cosmos DB**  | Multi-model, global distribution                     |

### 6.5 Redis Example (Conceptual)

```
> SET user:1001 '{"name":"Alice","email":"alice@email.com"}'
OK

> GET user:1001
'{"name":"Alice","email":"alice@email.com"}'

> SET session:xyz '{"userId":1001}' EX 3600
OK
(Expires in 3600 seconds = 1 hour)

> INCR page:views:home
(integer) 1
> INCR page:views:home
(integer) 2
> INCR page:views:home
(integer) 3

> LPUSH cart:1001 '{"productId":1,"qty":2}'
(integer) 1
> LPUSH cart:1001 '{"productId":5,"qty":1}'
(integer) 2
> LRANGE cart:1001 0 -1
1) '{"productId":5,"qty":1}'
2) '{"productId":1,"qty":2}'
```

---

## 7. Column-Family Databases

### 7.1 How Column-Family Databases Work

Data is stored in **column families** — groups of related columns that are
stored together. Unlike RDBMS tables, different rows can have different columns.

### 7.2 Structure

```
RDBMS Table (every row has ALL columns):
┌────────┬───────┬───────┬──────────┬─────────┐
│ UserID │ Name  │ Email │ Phone    │ Address │
├────────┼───────┼───────┼──────────┼─────────┤
│ 1      │ Alice │ a@e   │ 555-0101 │ NYC     │
│ 2      │ Bob   │ b@e   │ NULL     │ NULL    │  ← wastes space for NULLs
│ 3      │ Carol │ c@e   │ 555-0303 │ NULL    │
└────────┴───────┴───────┴──────────┴─────────┘

Column-Family (each row has only the columns it needs):
Row Key: 1
  ├── profile:name  = "Alice"
  ├── profile:email = "a@e"
  ├── contact:phone = "555-0101"
  └── contact:addr  = "NYC"

Row Key: 2
  ├── profile:name  = "Bob"
  └── profile:email = "b@e"
  (No phone or address — no wasted space!)

Row Key: 3
  ├── profile:name  = "Carol"
  ├── profile:email = "c@e"
  └── contact:phone = "555-0303"
```

### 7.3 Use Cases

| Use Case                | Why Column-Family?                              |
| ----------------------- | ----------------------------------------------- |
| **Time-Series Data**    | Write-heavy, append-only, sorted by time        |
| **IoT Sensor Data**     | High ingestion rate, millions of devices         |
| **Analytics / BI**      | Column-oriented reads are efficient for aggregation |
| **Logging / Metrics**   | Massive write throughput                         |
| **Recommendation Data** | Sparse data with varying attributes              |

### 7.4 Popular Column-Family Databases

| Database        | Developer     | Key Feature                             |
| --------------- | ------------- | --------------------------------------- |
| **Cassandra**   | Apache        | Highly available, peer-to-peer, no SPOF |
| **HBase**       | Apache        | Built on HDFS, strong consistency       |
| **ScyllaDB**    | ScyllaDB Inc  | C++ rewrite of Cassandra, faster        |
| **Bigtable**    | Google Cloud  | Managed, inspired Cassandra & HBase     |

---

## 8. Graph Databases

### 8.1 How Graph Databases Work

Data is stored as **nodes** (entities) and **edges** (relationships). Each node
and edge can have **properties** (key-value pairs).

### 8.2 Graph Structure

```
(Alice)──FRIENDS_WITH──>(Bob)
   │                      │
   │                      │
  LIKES                  LIKES
   │                      │
   ▼                      ▼
(Laptop)              (Keyboard)
   │                      │
   │                      │
  IN_CATEGORY          IN_CATEGORY
   │                      │
   ▼                      ▼
(Electronics)         (Electronics)

Nodes:  Alice, Bob, Laptop, Keyboard, Electronics
Edges:  FRIENDS_WITH, LIKES, IN_CATEGORY
Properties on nodes:  Alice {age: 28}, Laptop {price: 1299.99}
Properties on edges:  FRIENDS_WITH {since: "2020-01-15"}
```

### 8.3 Why Graphs?

In RDBMS, finding "friends of friends" requires multiple self-JOINs:

```sql
-- RDBMS: Find friends of friends of Alice (3 JOINs!)
SELECT DISTINCT p3.Name
FROM People p1
JOIN Friendships f1 ON p1.PersonID = f1.PersonID
JOIN Friendships f2 ON f1.FriendID = f2.PersonID
JOIN People p3       ON f2.FriendID = p3.PersonID
WHERE p1.Name = 'Alice'
  AND p3.PersonID <> p1.PersonID;
-- Gets slower with each level of depth
```

```
-- Graph Database: Same query (Cypher — Neo4j's query language)
MATCH (alice:Person {name: "Alice"})-[:FRIENDS_WITH*2]->(fof:Person)
WHERE fof <> alice
RETURN DISTINCT fof.name;
-- Naturally efficient for traversing relationships at ANY depth!
```

### 8.4 Use Cases

| Use Case                   | Why Graph?                                     |
| -------------------------- | ---------------------------------------------- |
| **Social Networks**        | Friends, followers, connections                |
| **Recommendation Engines** | "People who bought X also bought Y"            |
| **Fraud Detection**        | Trace money flow through networks              |
| **Knowledge Graphs**       | Interconnected entities (Wikipedia, Google)     |
| **Network/IT Management**  | Device dependencies, impact analysis           |
| **Route Optimization**     | Shortest path, logistics                       |

### 8.5 Popular Graph Databases

| Database            | Query Language      | Key Feature                       |
| ------------------- | ------------------- | --------------------------------- |
| **Neo4j**           | Cypher              | Most popular, ACID-compliant      |
| **Amazon Neptune**  | Gremlin, SPARQL     | Managed, AWS integrated           |
| **ArangoDB**        | AQL                 | Multi-model (doc + graph + KV)    |
| **JanusGraph**      | Gremlin             | Distributed, open-source          |
| **Cosmos DB**       | Gremlin             | Multi-model, global distribution  |

### 8.6 Cypher Query Examples (Neo4j)

```cypher
// Create nodes
CREATE (alice:Person {name: "Alice", age: 28})
CREATE (bob:Person {name: "Bob", age: 30})
CREATE (laptop:Product {name: "Laptop Pro 15", price: 1299.99})

// Create relationships
CREATE (alice)-[:FRIENDS_WITH {since: "2020-01-15"}]->(bob)
CREATE (alice)-[:PURCHASED {date: "2025-03-01"}]->(laptop)
CREATE (bob)-[:REVIEWED {rating: 5}]->(laptop)

// Query: What did Alice purchase?
MATCH (alice:Person {name: "Alice"})-[:PURCHASED]->(product)
RETURN product.name, product.price

// Query: Find recommendations for Alice
// (products purchased by her friends that she hasn't bought)
MATCH (alice:Person {name: "Alice"})-[:FRIENDS_WITH]->(friend)-[:PURCHASED]->(rec)
WHERE NOT (alice)-[:PURCHASED]->(rec)
RETURN DISTINCT rec.name, rec.price
```

---

## 9. RDBMS vs NoSQL — Detailed Comparison

### 9.1 Side-by-Side Comparison

| Dimension            | RDBMS                           | NoSQL                            |
| -------------------- | ------------------------------- | -------------------------------- |
| **Data Model**       | Tables (rows & columns)         | Documents, KV, columns, graphs   |
| **Schema**           | Fixed (schema-on-write)         | Flexible (schema-on-read)        |
| **Scaling**          | Primarily vertical              | Primarily horizontal             |
| **Consistency**      | Strong (ACID)                   | Varies (eventual to strong)      |
| **Transactions**     | Full multi-table transactions   | Limited (usually single-doc)     |
| **Relationships**    | JOINs between tables            | Embedded/referenced documents    |
| **Query Language**   | SQL (standardized)              | Database-specific                |
| **Maturity**         | 50+ years                       | ~15 years (modern era)           |
| **Tooling**          | Rich, mature ecosystem          | Growing, varies by database      |
| **Normalization**    | Encouraged (reduce redundancy)  | Denormalization often preferred  |
| **Read Performance** | Good with indexes               | Excellent (data locality)        |
| **Write Performance**| Good                            | Excellent (distributed writes)   |
| **Complex Queries**  | Excellent (SQL is powerful)     | Varies (some lack JOINs)        |

### 9.2 Data Modeling Approaches

```
RDBMS: NORMALIZE the data (reduce redundancy)
┌──────────┐     ┌─────────────┐     ┌──────────┐
│ Customers│     │   Orders    │     │ Products │
│──────────│     │─────────────│     │──────────│
│ ID       │←───→│ CustomerID  │     │ ID       │
│ Name     │     │ OrderDate   │←───→│ Name     │
│ Email    │     │ Status      │     │ Price    │
└──────────┘     └─────────────┘     └──────────┘
  + No data duplication                - Requires JOINs
  + Easy to update one place           - Can be slower for reads

NoSQL: DENORMALIZE the data (embed related data together)
{
  "orderId": 1,
  "customer": {
    "name": "Alice",
    "email": "alice@email.com"
  },
  "items": [
    { "product": "Laptop Pro 15", "price": 1299.99, "qty": 1 },
    { "product": "Wireless Mouse", "price": 29.99, "qty": 2 }
  ],
  "status": "Delivered"
}
  + Faster reads (all data in one place)   - Data duplication
  + No JOINs needed                        - Updates may need multiple docs
```

### 9.3 Transaction Comparison

```sql
-- RDBMS: Multi-table transaction (ACID guaranteed)
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 500 WHERE ID = 1;
    UPDATE Accounts SET Balance = Balance + 500 WHERE ID = 2;
    INSERT INTO Transactions (FromID, ToID, Amount) VALUES (1, 2, 500);
COMMIT;
-- All three succeed OR all three fail — guaranteed.
```

```javascript
// MongoDB: Single-document "transaction" (atomic by default)
db.accounts.updateOne(
  { _id: 1 },
  { $inc: { balance: -500 }, $push: { history: { to: 2, amount: 500 } } }
);
// Only ONE document is atomic. The matching credit to account 2
// is a SEPARATE operation that could fail independently.

// MongoDB 4.0+ supports multi-document transactions, but they're
// more expensive and should be used sparingly.
```

### 9.4 Decision Matrix

```
Choose RDBMS when:                    Choose NoSQL when:
───────────────────────────           ───────────────────────────
✅ Data is highly structured           ✅ Data is semi/unstructured
✅ Complex queries with JOINs          ✅ Simple queries by key/ID
✅ ACID transactions are critical      ✅ High write throughput needed
✅ Data integrity is paramount         ✅ Massive horizontal scale needed
✅ Mature tooling is important         ✅ Flexible/evolving schema
✅ Reporting and analytics             ✅ Real-time with low latency
✅ Financial/healthcare/government     ✅ Content management, IoT, gaming
```

---

## 10. When and Why to Use NoSQL

### 10.1 Good Fit for NoSQL

| Scenario                           | Recommended NoSQL Type   | Example Database  |
| ---------------------------------- | ------------------------ | ----------------- |
| Content management system          | Document                 | MongoDB           |
| User profiles with varying fields  | Document                 | Cosmos DB         |
| Shopping cart / sessions           | Key-Value                | Redis             |
| Real-time leaderboards             | Key-Value (sorted sets)  | Redis             |
| IoT sensor data (time-series)      | Column-Family            | Cassandra         |
| Social network connections         | Graph                    | Neo4j             |
| Product recommendations            | Graph                    | Amazon Neptune    |
| Caching layer for RDBMS            | Key-Value                | Redis / Memcached |
| Global low-latency reads           | Multi-model              | Cosmos DB         |
| Event logging / analytics          | Column-Family            | Cassandra / HBase |

### 10.2 Bad Fit for NoSQL

| Scenario                                 | Why RDBMS is better                    |
| ---------------------------------------- | -------------------------------------- |
| Complex transactions (banking, payroll)  | ACID guarantees, multi-table integrity |
| Complex reporting with many JOINs        | SQL's query power is unmatched         |
| Data that rarely changes structure       | Fixed schema prevents errors           |
| Regulatory compliance (audit trails)     | Strong consistency, mature tooling     |
| Small to medium datasets                 | RDBMS handles these perfectly          |

### 10.3 The Polyglot Persistence Pattern

Real-world applications often combine multiple databases:

```
┌──────────────────────────────────────────────────────────────────┐
│                     E-Commerce Application                       │
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐ │
│  │  SQL Server   │   │   MongoDB    │   │       Redis          │ │
│  │              │   │              │   │                      │ │
│  │ - Orders     │   │ - Product    │   │ - Session cache      │ │
│  │ - Payments   │   │   Catalog    │   │ - Shopping carts     │ │
│  │ - Inventory  │   │ - Reviews    │   │ - Page cache         │ │
│  │ - Accounts   │   │ - CMS pages  │   │ - Rate limiting      │ │
│  │              │   │              │   │                      │ │
│  │ WHY: ACID,   │   │ WHY: Flexible│   │ WHY: Speed,          │ │
│  │ complex      │   │ schema,      │   │ in-memory,           │ │
│  │ transactions │   │ varied       │   │ TTL support          │ │
│  │              │   │ product types│   │                      │ │
│  └──────────────┘   └──────────────┘   └──────────────────────┘ │
│                                                                  │
│  ┌──────────────┐   ┌──────────────────────────────────────────┐ │
│  │    Neo4j      │   │          Azure Cosmos DB                 │ │
│  │              │   │                                          │ │
│  │ - "Customers │   │ - Global product search                  │ │
│  │   also       │   │ - Multi-region replication               │ │
│  │   bought"    │   │ - Low-latency reads worldwide            │ │
│  │ - Social     │   │                                          │ │
│  │   features   │   │ WHY: Global distribution, SLA-backed     │ │
│  └──────────────┘   └──────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 11. NoSQL Demo — Basic CRUD Operations

### 11.1 MongoDB CRUD (Using Mongo Shell Syntax)

We'll demonstrate basic CRUD (Create, Read, Update, Delete) operations using
MongoDB's syntax. Even if you don't have MongoDB installed, understanding the
syntax helps you compare it with T-SQL.

#### Setup: Connect and Create a Database

```javascript
// In MongoDB, databases and collections are created implicitly
// when you first insert data.

// Switch to (or create) the RetailDB database
use RetailDB

// The "products" collection will be created on first insert
```

#### CREATE (Insert)

```javascript
// Insert a single document
db.products.insertOne({
    name: "Laptop Pro 15",
    category: "Electronics",
    price: 1299.99,
    stock: 50,
    specifications: {
        cpu: "Intel Core i7",
        ram: "16GB",
        storage: "512GB SSD"
    },
    tags: ["laptop", "computer", "portable"],
    isActive: true,
    createdAt: new Date()
});

// Insert multiple documents
db.products.insertMany([
    {
        name: "Wireless Mouse",
        category: "Electronics",
        price: 29.99,
        stock: 200,
        tags: ["mouse", "wireless", "accessory"],
        isActive: true
    },
    {
        name: "Cotton T-Shirt",
        category: "Clothing",
        price: 19.99,
        stock: 500,
        sizes: ["XS", "S", "M", "L", "XL"],
        material: "100% Cotton",
        isActive: true
    },
    {
        name: "SQL in 24 Hours",
        category: "Books",
        price: 34.99,
        stock: 80,
        author: "Ryan Stephens",
        pages: 600,
        isbn: "978-0672337598",
        isActive: true
    }
]);
```

**Equivalent T-SQL:**

```sql
INSERT INTO Products (ProductName, CategoryID, Price, Stock)
VALUES ('Laptop Pro 15', 1, 1299.99, 50);
-- But specifications, tags, etc. would need SEPARATE tables in RDBMS!
```

#### READ (Find / Query)

```javascript
// Find all products
db.products.find();

// Find all products (formatted)
db.products.find().pretty();

// Find by exact match
db.products.find({ category: "Electronics" });

// Find with comparison operators
db.products.find({ price: { $gt: 50 } });         // price > 50
db.products.find({ price: { $lte: 30 } });        // price <= 30
db.products.find({ price: { $gte: 20, $lte: 50 } }); // between 20 and 50

// Find with logical operators
db.products.find({
    $and: [
        { category: "Electronics" },
        { price: { $lt: 100 } }
    ]
});

// Find with OR
db.products.find({
    $or: [
        { category: "Books" },
        { category: "Clothing" }
    ]
});

// Find with projection (select specific fields)
db.products.find(
    { category: "Electronics" },
    { name: 1, price: 1, _id: 0 }  // 1 = include, 0 = exclude
);

// Find by array element
db.products.find({ tags: "laptop" });

// Find by nested field
db.products.find({ "specifications.ram": "16GB" });

// Sort, limit, skip (pagination)
db.products.find()
    .sort({ price: -1 })    // descending
    .limit(5)                // top 5
    .skip(0);                // offset 0

// Count documents
db.products.countDocuments({ isActive: true });

// Find one (first match)
db.products.findOne({ name: "Laptop Pro 15" });
```

**Equivalent T-SQL:**

```sql
-- Find by category
SELECT * FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Electronics';

-- Find with price range
SELECT * FROM Products WHERE Price BETWEEN 20 AND 50;

-- Pagination
SELECT ProductName, Price FROM Products
ORDER BY Price DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
```

#### UPDATE

```javascript
// Update one document
db.products.updateOne(
    { name: "Laptop Pro 15" },                // filter
    { $set: { price: 1199.99, stock: 45 } }   // update
);

// Update with increment
db.products.updateOne(
    { name: "Wireless Mouse" },
    { $inc: { stock: 50 } }    // increase stock by 50
);

// Update multiple documents
db.products.updateMany(
    { category: "Electronics" },
    { $set: { isActive: true } }
);

// Add an element to an array
db.products.updateOne(
    { name: "Laptop Pro 15" },
    { $push: { tags: "premium" } }
);

// Upsert (insert if not found, update if found)
db.products.updateOne(
    { name: "Tablet Ultra" },
    { $set: { name: "Tablet Ultra", category: "Electronics", price: 599.99, stock: 40 } },
    { upsert: true }
);
```

**Equivalent T-SQL:**

```sql
-- Update one
UPDATE Products SET Price = 1199.99, Stock = 45
WHERE ProductName = 'Laptop Pro 15';

-- Increment
UPDATE Products SET Stock = Stock + 50
WHERE ProductName = 'Wireless Mouse';

-- No direct equivalent for $push on arrays — need a separate table
```

#### DELETE

```javascript
// Delete one document
db.products.deleteOne({ name: "Tablet Ultra" });

// Delete multiple documents
db.products.deleteMany({ isActive: false });

// Delete all documents in a collection (like TRUNCATE)
db.products.deleteMany({});

// Drop the entire collection (like DROP TABLE)
db.products.drop();
```

**Equivalent T-SQL:**

```sql
DELETE FROM Products WHERE ProductName = 'Tablet Ultra';
DELETE FROM Products WHERE IsActive = 0;
TRUNCATE TABLE Products;
DROP TABLE Products;
```

### 11.2 Aggregation Pipeline (MongoDB)

MongoDB's aggregation pipeline is similar to GROUP BY in SQL:

```javascript
// Revenue per category (like GROUP BY in SQL)
db.orders.aggregate([
    // Stage 1: Unwind the items array (like a JOIN)
    { $unwind: "$items" },

    // Stage 2: Group by category
    { $group: {
        _id: "$items.category",
        totalRevenue: { $sum: { $multiply: ["$items.price", "$items.qty"] } },
        totalOrders: { $sum: 1 }
    }},

    // Stage 3: Sort by revenue descending
    { $sort: { totalRevenue: -1 } },

    // Stage 4: Rename fields for output
    { $project: {
        category: "$_id",
        totalRevenue: 1,
        totalOrders: 1,
        _id: 0
    }}
]);
```

**Equivalent T-SQL:**

```sql
SELECT
    c.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
    COUNT(*) AS TotalOrders
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalRevenue DESC;
```

### 11.3 MongoDB vs T-SQL Cheat Sheet

| Operation         | T-SQL                                    | MongoDB                                      |
| ----------------- | ---------------------------------------- | -------------------------------------------- |
| Create DB         | `CREATE DATABASE db`                     | `use db` (implicit)                          |
| Create table/coll | `CREATE TABLE t (...)`                   | `db.createCollection("t")` (or implicit)     |
| Insert one        | `INSERT INTO t VALUES (...)`             | `db.t.insertOne({...})`                      |
| Insert many       | `INSERT INTO t VALUES (...), (...)`      | `db.t.insertMany([{...}, {...}])`            |
| Select all        | `SELECT * FROM t`                        | `db.t.find()`                                |
| Select filtered   | `SELECT * FROM t WHERE col = 'x'`       | `db.t.find({ col: "x" })`                   |
| Select columns    | `SELECT col1, col2 FROM t`              | `db.t.find({}, { col1: 1, col2: 1 })`       |
| Update            | `UPDATE t SET col = 'y' WHERE ...`       | `db.t.updateOne({...}, { $set: {col:"y"} })` |
| Delete            | `DELETE FROM t WHERE ...`                | `db.t.deleteOne({...})`                      |
| Count             | `SELECT COUNT(*) FROM t`                | `db.t.countDocuments()`                      |
| Order by          | `SELECT * FROM t ORDER BY col DESC`     | `db.t.find().sort({ col: -1 })`             |
| Limit             | `SELECT TOP 5 * FROM t`                | `db.t.find().limit(5)`                       |
| Group by          | `SELECT col, COUNT(*) ... GROUP BY col` | `db.t.aggregate([{ $group: ... }])`          |
| Drop table        | `DROP TABLE t`                           | `db.t.drop()`                                |

---

## 12. Introduction to Cloud Databases

### 12.1 What Are Cloud Databases?

Cloud databases are database services hosted and managed by cloud providers.
Instead of buying servers and managing software, you rent database capacity.

### 12.2 Cloud Database Models

```
┌───────────────────────────���────────────────────────────────────┐
│                   Cloud Database Models                         │
├──────────────────┬───────────────────┬─────────────────────────┤
│     IaaS         │      PaaS         │        SaaS             │
│ (VM + DB)        │ (Managed DB)      │  (Fully Managed)        │
│                  │                   │                         │
│ You manage:      │ You manage:       │ You manage:             │
│ - OS patches     │ - Schema          │ - Nothing (just use it) │
│ - DB installs    │ - Queries         │                         │
│ - Backups        │ - Indexes         │ Provider manages:       │
│ - Scaling        │                   │ - Everything            │
│ - Everything     │ Provider manages: │                         │
│                  │ - OS, patches     │ Examples:               │
│ Examples:        │ - Backups         │ - Firebase              │
│ - SQL Server     │ - HA / failover   │ - Airtable              │
│   on Azure VM   │ - Scaling         │ - Supabase              │
│ - PostgreSQL     │                   │                         │
│   on EC2        │ Examples:         │                         │
│                  │ - Azure SQL DB    │                         │
│                  │ - Amazon RDS      │                         │
│                  │ - Cloud SQL (GCP) │                         │
└──────────────────┴───────────────────┴─────────────────────────┘

Control ←──────────────────────────────────────────→ Convenience
More control                                        Less management
(IaaS)                                              (SaaS)
```

### 12.3 Major Cloud Database Providers

| Provider  | Relational                    | NoSQL                          |
| --------- | ----------------------------- | ------------------------------ |
| **Azure** | Azure SQL, Azure Database for MySQL/PostgreSQL | Cosmos DB, Table Storage |
| **AWS**   | RDS, Aurora                   | DynamoDB, DocumentDB, Neptune  |
| **GCP**   | Cloud SQL, Spanner            | Firestore, Bigtable            |

---

## 13. Introduction to Azure SQL Database

### 13.1 What Is Azure SQL Database?

**Azure SQL Database** is a fully managed relational database service built on
the SQL Server engine. It runs in the Azure cloud and is managed by Microsoft.

### 13.2 Azure SQL Family

```
┌──────────────────────────────────────────────────────────────┐
│                    Azure SQL Family                           │
├────────────────────┬──────────────────┬──────────────────────┤
│  Azure SQL         │  Azure SQL       │  SQL Server          │
│  Database          │  Managed Instance│  on Azure VMs        │
│                    │                  │                      │
│  PaaS (managed)    │  PaaS (managed)  │  IaaS (you manage)   │
│                    │                  │                      │
│  Single database   │  Near 100%       │  Full SQL Server     │
│  or Elastic Pool   │  compatibility   │  control             │
│                    │  with on-prem    │                      │
│  Best for:         │  Best for:       │  Best for:           │
│  New cloud apps    │  Lift & shift    │  Full control        │
│  microservices     │  migration       │  legacy apps         │
└────────────────────┴──────────────────┴──────────────────────┘
```

### 13.3 Key Features of Azure SQL Database

| Feature                  | Description                                         |
| ------------------------ | --------------------------------------------------- |
| **Fully Managed**        | Microsoft handles patches, backups, HA               |
| **High Availability**    | 99.99% SLA built-in                                  |
| **Auto-Scaling**         | Scale compute and storage independently              |
| **Automatic Backups**    | Point-in-time restore up to 35 days                  |
| **Geo-Replication**      | Read replicas across Azure regions                   |
| **Advanced Security**    | TDE, Always Encrypted, AAD auth, threat detection    |
| **Intelligent Performance** | Auto-tuning, query performance insights           |
| **Serverless Tier**      | Auto-pause when idle (pay only when active)          |
| **Elastic Pools**        | Share resources across multiple databases             |
| **Compatibility**        | Based on latest SQL Server engine                    |

### 13.4 Purchasing Models

| Model               | Description                                           |
| -------------------- | ---------------------------------------------------- |
| **DTU-based**        | Bundled compute (CPU + I/O + memory). Simple pricing. |
| **vCore-based**      | Choose CPU cores, memory, storage independently.      |
| **Serverless**       | Auto-scales compute; pauses when idle.                |
| **Hyperscale**       | Up to 100 TB, rapid scale-out, instant backups.       |

```
DTU Model (Bundled):
  Basic:  5 DTUs,   2 GB  → ~$5/month
  Standard S0: 10 DTUs, 250 GB → ~$15/month
  Premium P1: 125 DTUs, 500 GB → ~$465/month

vCore Model (Flexible):
  General Purpose: 2-80 vCores, up to 4 TB
  Business Critical: 2-128 vCores, local SSD, built-in HA replica
  Hyperscale: 2-128 vCores, up to 100 TB, distributed architecture

Serverless:
  Min 0.5 vCores → Max 40 vCores
  Auto-pause after 1 hour of inactivity
  Pay per second of compute used
```

### 13.5 Connectivity Options

```
┌──────────────────────────────────────────────────────────────┐
│                   Connecting to Azure SQL                     │
│                                                              │
│  Tools:                                                      │
│  ├── SQL Server Management Studio (SSMS)                     │
│  ├── Azure Data Studio                                       │
│  ├── Visual Studio / VS Code (with extensions)               │
│  ├── sqlcmd (command line)                                   │
│  ├── Azure Portal (Query Editor — built in)                  │
│  └── Any application with an ODBC/JDBC/ADO.NET driver        │
│                                                              │
│  Connection String:                                          │
│  Server=tcp:yourserver.database.windows.net,1433;            │
│  Initial Catalog=YourDatabase;                               │
│  User ID=youradmin;                                          │
│  Password=YourPassword;                                      │
│  Encrypt=True;                                               │
│  TrustServerCertificate=False;                               │
│  Connection Timeout=30;                                      │
└──────────────────────────────────────────────────────────────┘
```

---

## 14. Demo: Creating and Managing Azure SQL Database

### 14.1 Creating via Azure Portal (Step-by-Step)

```
Step 1: Log in to Azure Portal (https://portal.azure.com)

Step 2: Create a Resource Group
  → Search "Resource Groups" → Create
  → Name: rg-sql-course
  → Region: East US (or your preferred region)

Step 3: Create SQL Server (logical server)
  → Search "SQL servers" → Create
  → Resource Group: rg-sql-course
  → Server Name: sql-course-server (must be globally unique)
  → Location: East US
  → Authentication: SQL authentication
  → Admin: sqladmin
  → Password: (strong password)

Step 4: Create SQL Database
  → Search "SQL databases" → Create
  → Resource Group: rg-sql-course
  → Database Name: RetailDB
  → Server: sql-course-server
  → Compute + Storage: Configure
    → Service Tier: Basic (for learning) or Serverless (pay-per-use)
  → Backup: Locally-redundant (cheapest for learning)

Step 5: Configure Firewall
  → Go to your SQL server → Networking
  → Add your client IP address
  → Enable "Allow Azure services" (for other Azure tools)

Step 6: Connect!
  → Use SSMS, Azure Data Studio, or the portal's Query Editor
```

### 14.2 Creating via Azure CLI

```bash
# Login to Azure
az login

# Create a resource group
az group create \
  --name rg-sql-course \
  --location eastus

# Create a logical SQL server
az sql server create \
  --name sql-course-server \
  --resource-group rg-sql-course \
  --location eastus \
  --admin-user sqladmin \
  --admin-password "YourStr0ngP@ssword!"

# Configure firewall (allow your IP)
az sql server firewall-rule create \
  --resource-group rg-sql-course \
  --server sql-course-server \
  --name AllowMyIP \
  --start-ip-address YOUR_IP \
  --end-ip-address YOUR_IP

# Create a database (Basic tier)
az sql db create \
  --resource-group rg-sql-course \
  --server sql-course-server \
  --name RetailDB \
  --service-objective Basic

# Create a database (Serverless tier)
az sql db create \
  --resource-group rg-sql-course \
  --server sql-course-server \
  --name RetailDB_Serverless \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --family Gen5 \
  --min-capacity 0.5 \
  --capacity 2 \
  --auto-pause-delay 60
```

### 14.3 Creating via PowerShell

```powershell
# Login
Connect-AzAccount

# Create resource group
New-AzResourceGroup `
  -Name "rg-sql-course" `
  -Location "East US"

# Create SQL server
New-AzSqlServer `
  -ResourceGroupName "rg-sql-course" `
  -ServerName "sql-course-server" `
  -Location "East US" `
  -SqlAdministratorCredentials (Get-Credential)

# Create firewall rule
New-AzSqlServerFirewallRule `
  -ResourceGroupName "rg-sql-course" `
  -ServerName "sql-course-server" `
  -FirewallRuleName "AllowMyIP" `
  -StartIpAddress "YOUR_IP" `
  -EndIpAddress "YOUR_IP"

# Create database
New-AzSqlDatabase `
  -ResourceGroupName "rg-sql-course" `
  -ServerName "sql-course-server" `
  -DatabaseName "RetailDB" `
  -Edition "Basic"
```

### 14.4 Running T-SQL on Azure SQL Database

Once connected, you use the **same T-SQL** you've been learning all week!

```sql
-- =============================================
-- This is EXACTLY the same T-SQL as on-premises!
-- =============================================

-- Create tables
CREATE TABLE dbo.Products (
    ProductID   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT           NOT NULL DEFAULT 0
);

-- Insert data
INSERT INTO dbo.Products (ProductName, Price, Stock)
VALUES
    (N'Cloud Widget',   49.99, 100),
    (N'Azure Gadget',  149.99,  50),
    (N'SQL Toolkit',    29.99, 200);

-- Query data
SELECT * FROM dbo.Products ORDER BY Price DESC;

-- Create a stored procedure
CREATE PROCEDURE dbo.usp_GetProductsByPrice
    @MinPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductName, Price, Stock
    FROM dbo.Products
    WHERE Price >= @MinPrice
    ORDER BY Price;
END;
GO

-- Execute it
EXEC dbo.usp_GetProductsByPrice @MinPrice = 50.00;
```

### 14.5 Azure-Specific Features Demo

```sql
-- =============================================
-- Azure SQL Database specific features
-- =============================================

-- Check your database edition and service tier
SELECT
    DATABASEPROPERTYEX(DB_NAME(), 'Edition')       AS Edition,
    DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS ServiceTier;

-- Check database size
SELECT
    DB_NAME() AS DatabaseName,
    SUM(size * 8.0 / 1024) AS SizeMB
FROM sys.database_files;

-- View current resource usage (DTU or vCore)
SELECT
    end_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;

-- Check active connections
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

-- View automatic tuning recommendations
SELECT
    reason,
    score,
    details ->> '$.implementationDetails.script' AS RecommendedScript
FROM sys.dm_db_tuning_recommendations
WHERE state ->> '$.currentValue' = 'Active';
```

### 14.6 Managing Backups and Restore

```sql
-- Azure SQL handles backups automatically!
-- You can restore to any point in time (up to 35 days)

-- Via Azure CLI:
-- az sql db restore \
--   --resource-group rg-sql-course \
--   --server sql-course-server \
--   --name RetailDB_Restored \
--   --dest-name RetailDB_Restored \
--   --time "2025-03-28T12:00:00"

-- Check backup history (long-term retention)
SELECT *
FROM sys.dm_database_copies;
```

### 14.7 Geo-Replication

```sql
-- Set up a read-replica in another region (via Azure Portal or CLI):
-- az sql db replica create \
--   --resource-group rg-sql-course \
--   --server sql-course-server \
--   --name RetailDB \
--   --partner-server sql-course-server-westus \
--   --partner-resource-group rg-sql-course-west

-- Your application can read from the replica:
-- Connection string for READ replica:
-- Server=tcp:sql-course-server-westus.database.windows.net,1433;
-- ApplicationIntent=ReadOnly;
-- ...
```

---

## 15. Azure SQL vs On-Premises SQL Server

### 15.1 Feature Comparison

| Feature                    | On-Premises SQL Server   | Azure SQL Database          |
| -------------------------- | ----------------------- | --------------------------- |
| **Management**             | You manage everything    | Microsoft manages infra     |
| **Licensing**              | License purchase/SA      | Pay-as-you-go               |
| **High Availability**      | Manual (Always On, FCI) | Built-in (99.99% SLA)      |
| **Backups**                | Manual configuration     | Automatic (PITR up to 35d) |
| **Scaling**                | Hardware changes         | Portal slider / API call    |
| **Patching**               | Manual (monthly)         | Automatic                   |
| **Disaster Recovery**      | Manual geo-replication   | Geo-replication built-in    |
| **Security**               | Your responsibility      | Advanced threat protection  |
| **Cost Model**             | CapEx (buy hardware)     | OpEx (pay per use)          |
| **SQL Agent**              | ✅ Full support          | ❌ Use Elastic Jobs instead |
| **CLR Integration**        | ✅ Full support          | ❌ Not supported            |
| **Cross-DB Queries**       | ✅ Full support          | ⚠️ Limited (Elastic Query)  |
| **Linked Servers**         | ✅ Full support          | ❌ Not supported            |
| **Full T-SQL**             | ✅ Complete              | ⚠️ ~95% compatible          |

### 15.2 What's Different in Azure SQL?

```sql
-- These work the same:
CREATE TABLE, ALTER TABLE, DROP TABLE
SELECT, INSERT, UPDATE, DELETE, MERGE
CREATE VIEW, CREATE PROCEDURE, CREATE FUNCTION
Indexes, Constraints, Triggers
TRY-CATCH, Transactions
JOINs, Subqueries, CTEs, Window Functions

-- These are different or unavailable:
-- ❌ USE database;  (must connect to specific DB directly)
-- ❌ CREATE DATABASE ... ON (filegroups)
-- ❌ SQL Server Agent (use Azure Automation / Elastic Jobs)
-- ❌ Linked Servers
-- ❌ CLR assemblies
-- ❌ BULK INSERT from local files (use Azure Blob Storage)
-- ❌ xp_cmdshell
-- ⚠️ Some system views/DMVs have different names or behavior
```

### 15.3 Migration Considerations

```
┌─────────────────────────────────────────────────────────────────┐
│                Migration Decision Tree                           │
│                                                                 │
│  Need 100% SQL Server compatibility?                            │
│  ├── Yes → Azure SQL Managed Instance or SQL Server on VM       │
│  └── No → Azure SQL Database (recommended for most new apps)    │
│                                                                 │
│  Have SQL Agent jobs?                                           │
│  ├── Yes → Migrate to Elastic Jobs or Azure Automation          │
│  └── No → No action needed                                     │
│                                                                 │
│  Use cross-database queries?                                    │
│  ├── Yes → Consider Managed Instance or refactor                │
│  └── No → Azure SQL Database works great                        │
│                                                                 │
│  Need CLR or Linked Servers?                                    │
│  ├── Yes → Managed Instance or SQL Server on VM                 │
│  └── No → Azure SQL Database                                   │
│                                                                 │
│  Tools for migration:                                           │
│  ├── Data Migration Assistant (DMA) — assess compatibility      │
│  ├── Azure Database Migration Service — migrate data            │
│  └── BACPAC export/import — simple database migration           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 16. Other Azure Data Services

### 16.1 Azure Data Services Landscape

| Service                     | Type           | Best For                                  |
| --------------------------- | -------------- | ----------------------------------------- |
| **Azure SQL Database**      | Relational     | OLTP, web apps, microservices             |
| **Azure SQL Managed Instance** | Relational  | Lift-and-shift from on-prem SQL Server    |
| **Azure Cosmos DB**         | Multi-model    | Global distribution, low latency           |
| **Azure Database for MySQL** | Relational    | MySQL workloads in the cloud              |
| **Azure Database for PostgreSQL** | Relational | PostgreSQL workloads in the cloud      |
| **Azure Cache for Redis**   | Key-Value      | Caching, sessions, real-time              |
| **Azure Table Storage**     | Key-Value      | Simple NoSQL, low cost                    |
| **Azure Blob Storage**      | Object         | Files, images, videos, backups            |
| **Azure Synapse Analytics** | Analytics      | Data warehousing, big data analytics      |
| **Azure Data Factory**      | ETL/ELT        | Data integration and pipelines            |
| **Azure Databricks**        | Analytics      | Apache Spark, ML, data engineering        |

### 16.2 Azure Cosmos DB (Brief Overview)

Azure Cosmos DB is Microsoft's globally distributed, multi-model database.

```
Cosmos DB APIs:
├── SQL (Core) API       → Document (JSON), SQL-like queries
├── MongoDB API          → MongoDB-compatible
├── Cassandra API        → Apache Cassandra-compatible
├── Gremlin API          → Graph database
└── Table API            → Azure Table Storage-compatible

Key Features:
- Global distribution (replicate to any Azure region)
- Single-digit millisecond latency (guaranteed)
- Five consistency levels (Strong → Eventual)
- Multi-model (documents, graphs, key-value, column-family)
- Automatic indexing (every field is indexed by default)
- 99.999% availability SLA (with multi-region writes)
```

### 16.3 Cosmos DB Quick Example (SQL API)

```sql
-- Cosmos DB uses a SQL-like syntax for its Core API

-- Create a document (via SDK or portal)
-- Container: Products, Partition Key: /category

-- Query documents (looks like SQL!)
SELECT
    p.name,
    p.price,
    p.category,
    p.specifications.cpu
FROM Products p
WHERE p.category = "Electronics"
  AND p.price > 100
ORDER BY p.price DESC

-- Array operations
SELECT
    p.name,
    t AS tag
FROM Products p
JOIN t IN p.tags
WHERE t = "laptop"

-- Aggregation
SELECT
    p.category,
    COUNT(1) AS productCount,
    AVG(p.price) AS avgPrice
FROM Products p
GROUP BY p.category
```

> **Note:** Cosmos DB's SQL API looks similar to T-SQL but has important
> differences (no JOINs between containers, different function names, etc.).

---

## 17. 5-Day Course Review

### 17.1 Complete Knowledge Map

```
Day 1: FOUNDATIONS
├── Databases & RDBMS concepts
├── Data models (hierarchical, network, relational)
├── ACID properties
├── Codd's 12 rules
├── Data types (numeric, string, date, others)
├── Schemas and tables
├── DDL: CREATE, ALTER, DROP, TRUNCATE
├── DML: SELECT, INSERT, UPDATE, DELETE
├── DCL: GRANT, REVOKE, DENY
└── Constraints: PK, FK, UNIQUE, CHECK, DEFAULT, NOT NULL

Day 2: CORE SQL
├── Variables and control flow (IF, WHILE, CASE)
├── String functions (LEN, SUBSTRING, CONCAT, STRING_AGG, ...)
├── Date functions (DATEADD, DATEDIFF, FORMAT, EOMONTH, ...)
├── Math functions (ROUND, CEILING, FLOOR, ABS, ...)
├── Conversion (CAST, CONVERT, TRY_CAST, ...)
├── NULL handling (ISNULL, COALESCE, NULLIF)
├── Aggregates (COUNT, SUM, AVG, MIN, MAX)
├── GROUP BY, HAVING, ORDER BY, OFFSET-FETCH
├── Advanced DML (OUTPUT, MERGE, SELECT INTO)
└── Set operators (UNION, UNION ALL, INTERSECT, EXCEPT)

Day 3: DATA RETRIEVAL
├── INNER JOIN, LEFT JOIN, RIGHT JOIN
├── FULL OUTER JOIN, CROSS JOIN
├── Self joins (hierarchical data)
├── Multi-table join strategies
├── Non-correlated subqueries (scalar, multi-value, derived)
├── Correlated subqueries
├── EXISTS and NOT EXISTS
├── Common Table Expressions (CTEs)
├── Recursive CTEs (org charts, hierarchies)
└── Query optimization basics (SARGable, execution plans)

Day 4: DATABASE OBJECTS
├── Clustered indexes (B-tree, physical sort)
├── Non-clustered indexes (separate structure, pointers)
├── Covering indexes (INCLUDE), filtered indexes
├── Index design and maintenance
├── Views (simple, aggregated, security, updatable)
├── WITH CHECK OPTION, WITH SCHEMABINDING, indexed views
├── Stored procedures (params, OUTPUT, RETURN, transactions)
├── Dynamic SQL (QUOTENAME, sp_executesql)
├── TRY-CATCH (THROW, RAISERROR, error functions)
├── User-defined functions (scalar, inline TVF)
└── Triggers (AFTER, INSTEAD OF, inserted/deleted tables)

Day 5: BEYOND RDBMS
├── NoSQL history and motivation
├── CAP theorem, ACID vs BASE
├── Document databases (MongoDB, Cosmos DB)
├── Key-value stores (Redis, DynamoDB)
├── Column-family databases (Cassandra, HBase)
├── Graph databases (Neo4j, Neptune)
├── RDBMS vs NoSQL comparison
├── When to use each type
├── NoSQL CRUD operations (MongoDB demo)
├── Cloud databases (IaaS, PaaS, SaaS)
├── Azure SQL Database (features, tiers, setup)
├── Azure SQL management (CLI, Portal, PowerShell)
└── Other Azure data services (Cosmos DB, Redis, Synapse)
```

### 17.2 SQL Skills Progression

```
Beginner (Day 1-2):
  ✅ CREATE databases, schemas, tables
  ✅ INSERT, SELECT, UPDATE, DELETE
  ✅ WHERE, ORDER BY, GROUP BY, HAVING
  ✅ Data types, constraints, integrity
  ✅ Basic functions (string, date, math)

Intermediate (Day 3):
  ✅ All JOIN types
  ✅ Subqueries (correlated, non-correlated)
  ✅ CTEs (including recursive)
  ✅ Complex multi-table queries
  ✅ EXISTS / NOT EXISTS

Advanced (Day 4):
  ✅ Index design and optimization
  ✅ Views (including indexed views)
  ✅ Stored procedures with error handling
  ✅ User-defined functions
  ✅ Triggers

Modern (Day 5):
  ✅ Understand NoSQL trade-offs
  ✅ Know when to choose RDBMS vs NoSQL
  ✅ Work with cloud databases (Azure SQL)
  ✅ Awareness of the broader data ecosystem
```

---

## 18. Day 5 Summary

### What We Covered

| Topic                     | Key Takeaway                                            |
| ------------------------- | ------------------------------------------------------- |
| NoSQL History             | Driven by web-scale needs (volume, velocity, variety)   |
| CAP Theorem               | Distributed systems: pick 2 of 3 (C, A, P)             |
| ACID vs BASE              | Strong consistency vs eventual consistency              |
| Document Databases        | JSON documents, flexible schema, embedded data          |
| Key-Value Stores          | Fastest for simple get/set by key; great for caching    |
| Column-Family             | Wide rows, good for time-series and analytics           |
| Graph Databases           | Nodes + edges; best for relationship traversal          |
| RDBMS vs NoSQL            | Not either/or — use the right tool for the job          |
| Polyglot Persistence      | Modern apps often combine multiple database types       |
| Azure SQL Database        | Fully managed SQL Server in the cloud                   |
| Azure SQL Tiers           | DTU, vCore, Serverless, Hyperscale                      |
| Azure SQL Management      | Portal, CLI, PowerShell, SSMS, Azure Data Studio        |
| Azure Cosmos DB           | Multi-model, globally distributed, multi-API            |

### Decision Framework

```
Need to store data?
│
├── Is it structured with clear relationships?
│   ├── Yes → RDBMS (SQL Server, Azure SQL, PostgreSQL)
│   └── No  → Continue below
│
├── Is it semi-structured (JSON, varying fields)?
│   ├── Yes → Document DB (MongoDB, Cosmos DB)
│   └── No  → Continue below
│
├── Is it simple key → value lookups?
│   ├── Yes → Key-Value (Redis, DynamoDB)
│   └── No  → Continue below
│
├── Is it time-series or columnar analytics?
│   ├── Yes → Column-Family (Cassandra) or Time-Series DB
│   └── No  → Continue below
│
├── Is it highly connected data (relationships ARE the data)?
│   ├── Yes → Graph DB (Neo4j, Neptune)
│   └── No  → Continue below
│
└── Need global distribution with multiple models?
    └── Yes → Multi-model (Cosmos DB)
```

---

## 19. Hands-On Exercises

### Exercise 1: NoSQL Data Modeling

Given the following RDBMS schema, design the equivalent **document model**
(as JSON documents) for a NoSQL database:

```
Tables:
- Authors (AuthorID, FirstName, LastName, Country)
- Books (BookID, Title, ISBN, PublishedYear, Price, AuthorID)
- Members (MemberID, FullName, Email, JoinDate)
- Loans (LoanID, BookID, MemberID, LoanDate, ReturnDate)
```

Design TWO approaches:
1. **Author-centric** (embed books inside authors)
2. **Member-centric** (embed loans inside members)

Discuss the trade-offs of each approach.

<details>
<summary>💡 Click to reveal solution</summary>

**Approach 1: Author-Centric**

```json
// Authors collection
{
    "_id": "author_001",
    "firstName": "George",
    "lastName": "Orwell",
    "country": "United Kingdom",
    "books": [
        {
            "bookId": "book_001",
            "title": "1984",
            "isbn": "978-0451524935",
            "publishedYear": 1949,
            "price": 9.99
        },
        {
            "bookId": "book_002",
            "title": "Animal Farm",
            "isbn": "978-0451526342",
            "publishedYear": 1945,
            "price": 7.99
        }
    ]
}

// Pros:
// - Get all books by an author in ONE read
// - No JOINs needed for author + books
//
// Cons:
// - If a book has multiple authors, data is duplicated
// - Updating a book title requires updating all copies
// - Loans are in a separate collection → need multiple queries
```

**Approach 2: Member-Centric**

```json
// Members collection
{
    "_id": "member_001",
    "fullName": "Alice Johnson",
    "email": "alice@library.org",
    "joinDate": "2025-01-15",
    "loans": [
        {
            "loanId": "loan_001",
            "book": {
                "title": "1984",
                "author": "George Orwell",
                "isbn": "978-0451524935"
            },
            "loanDate": "2025-03-01",
            "returnDate": "2025-03-15"
        },
        {
            "loanId": "loan_002",
            "book": {
                "title": "Animal Farm",
                "author": "George Orwell",
                "isbn": "978-0451526342"
            },
            "loanDate": "2025-03-10",
            "returnDate": null
        }
    ]
}

// Pros:
// - Get a member's full loan history in ONE read
// - Perfect for "My Loans" page in an app
//
// Cons:
// - Book/author data is duplicated in every loan
// - Finding "all loans for a specific book" requires scanning all members
// - Array can grow very large for active members
```

**Trade-offs Discussion:**

| Aspect              | Author-Centric         | Member-Centric         |
| ------------------- | ---------------------- | ---------------------- |
| Best query          | "All books by author"  | "All loans by member"  |
| Worst query         | "All loans by member"  | "All loans for a book" |
| Data duplication    | Moderate               | High                   |
| Update complexity   | Moderate               | High                   |
| Array growth risk   | Low (authors write few books) | High (active members) |

**Best practice:** Choose the model based on your **most common access pattern**.

</details>

---

### Exercise 2: MongoDB CRUD Practice

Write MongoDB commands to perform the following operations on a `students`
collection:

1. Insert 5 students with fields: name, age, email, courses (array of objects with courseName and grade).
2. Find all students who are taking "Math".
3. Find students older than 20 with a grade above 80 in any course.
4. Update the grade for a specific student in a specific course.
5. Add a new course to a student's courses array.
6. Remove a student by name.
7. Find the average age of all students.
8. Find the student with the highest grade in "Science".

<details>
<summary>💡 Click to reveal solution</summary>

```javascript
// 1. Insert students
db.students.insertMany([
    {
        name: "Alice", age: 21, email: "alice@uni.edu",
        courses: [
            { courseName: "Math", grade: 92 },
            { courseName: "Science", grade: 88 }
        ]
    },
    {
        name: "Bob", age: 19, email: "bob@uni.edu",
        courses: [
            { courseName: "Math", grade: 75 },
            { courseName: "History", grade: 82 }
        ]
    },
    {
        name: "Charlie", age: 22, email: "charlie@uni.edu",
        courses: [
            { courseName: "Science", grade: 95 },
            { courseName: "Math", grade: 68 }
        ]
    },
    {
        name: "Diana", age: 20, email: "diana@uni.edu",
        courses: [
            { courseName: "Math", grade: 88 },
            { courseName: "Art", grade: 91 }
        ]
    },
    {
        name: "Eve", age: 23, email: "eve@uni.edu",
        courses: [
            { courseName: "Science", grade: 79 },
            { courseName: "History", grade: 85 }
        ]
    }
]);

// 2. Students taking Math
db.students.find({ "courses.courseName": "Math" });

// 3. Older than 20 with grade > 80
db.students.find({
    age: { $gt: 20 },
    "courses.grade": { $gt: 80 }
});

// 4. Update specific grade
db.students.updateOne(
    { name: "Bob", "courses.courseName": "Math" },
    { $set: { "courses.$.grade": 80 } }
);

// 5. Add a new course
db.students.updateOne(
    { name: "Alice" },
    { $push: { courses: { courseName: "History", grade: 85 } } }
);

// 6. Remove a student
db.students.deleteOne({ name: "Eve" });

// 7. Average age
db.students.aggregate([
    { $group: { _id: null, avgAge: { $avg: "$age" } } }
]);

// 8. Highest grade in Science
db.students.aggregate([
    { $unwind: "$courses" },
    { $match: { "courses.courseName": "Science" } },
    { $sort: { "courses.grade": -1 } },
    { $limit: 1 },
    { $project: { name: 1, grade: "$courses.grade", _id: 0 } }
]);
```

</details>

---

### Exercise 3: Azure SQL Database Setup

Answer the following questions and complete the tasks:

1. List the three main Azure SQL deployment options and when to use each.
2. What is the difference between the DTU-based and vCore-based purchasing models?
3. Write the Azure CLI commands to:
   a. Create a resource group in West Europe.
   b. Create a SQL server with SQL authentication.
   c. Add a firewall rule for your IP.
   d. Create a Serverless database.
4. After connecting to your Azure SQL Database, run the following and explain the output:
   - `SELECT @@VERSION;`
   - `SELECT DATABASEPROPERTYEX(DB_NAME(), 'Edition');`

<details>
<summary>💡 Click to reveal solution</summary>

**1. Three Azure SQL deployment options:**

| Option                  | Use When                                    |
| ----------------------- | ------------------------------------------- |
| Azure SQL Database      | New cloud-native apps, microservices        |
| Azure SQL Managed Instance | Migrating from on-prem (near 100% compat)|
| SQL Server on Azure VM  | Need full SQL Server control (CLR, Agent)   |

**2. DTU vs vCore:**

| DTU                              | vCore                                  |
| -------------------------------- | -------------------------------------- |
| Bundled CPU + I/O + Memory       | Choose CPU, memory, storage separately |
| Simpler pricing                  | More flexible                          |
| Good for predictable workloads   | Good for varying workloads             |
| Cannot independently scale parts | Scale compute and storage independently|

**3. Azure CLI commands:**

```bash
# a. Resource group
az group create --name rg-sql-europe --location westeurope

# b. SQL server
az sql server create \
  --name sql-europe-server \
  --resource-group rg-sql-europe \
  --location westeurope \
  --admin-user sqladmin \
  --admin-password "Str0ngP@ss123!"

# c. Firewall rule
az sql server firewall-rule create \
  --resource-group rg-sql-europe \
  --server sql-europe-server \
  --name MyIPRule \
  --start-ip-address 203.0.113.50 \
  --end-ip-address 203.0.113.50

# d. Serverless database
az sql db create \
  --resource-group rg-sql-europe \
  --server sql-europe-server \
  --name AppDB \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --family Gen5 \
  --min-capacity 0.5 \
  --capacity 4 \
  --auto-pause-delay 60
```

**4. Output explanation:**

```sql
SELECT @@VERSION;
-- Returns the SQL Server engine version running in Azure
-- e.g., "Microsoft SQL Azure (RTM) - 12.0.2000.8"
-- This confirms you're on Azure SQL (not on-premises)

SELECT DATABASEPROPERTYEX(DB_NAME(), 'Edition');
-- Returns the service tier: 'Basic', 'Standard', 'Premium',
-- 'GeneralPurpose', 'BusinessCritical', or 'Hyperscale'
```

</details>

---

### Exercise 4: RDBMS vs NoSQL Decision Making

For each scenario below, decide whether you would use **RDBMS**, **NoSQL**
(and which type), or **both**. Justify your answer.

1. A banking application that processes millions of financial transactions per day.
2. A social media platform that needs to show "People You May Know" suggestions.
3. An IoT platform receiving 100,000 sensor readings per second.
4. A content management system where articles have widely varying structures.
5. A gaming platform that needs real-time leaderboards and player sessions.
6. A hospital records system that must comply with strict data integrity regulations.
7. A recommendation engine for an e-commerce site ("Customers who bought X also bought Y").
8. A startup building an MVP that expects the data model to change frequently.

<details>
<summary>💡 Click to reveal solution</summary>

| # | Scenario               | Choice              | Justification                                 |
|---|------------------------|---------------------|----------------------------------------------|
| 1 | Banking transactions   | **RDBMS**           | ACID is critical for financial data. Strong consistency, multi-table transactions, regulatory compliance. |
| 2 | Social "People You May Know" | **Graph DB** (Neo4j / Neptune) | Relationship traversal is the core operation. Finding friends-of-friends at any depth is natural for graphs. |
| 3 | IoT sensor readings    | **Column-Family** (Cassandra / HBase) | Massive write throughput, time-series data, horizontal scaling. Possibly **also** an RDBMS for aggregated reports. |
| 4 | CMS with varying content | **Document DB** (MongoDB / Cosmos DB) | Articles with different structures (blog vs. video vs. gallery) fit naturally into flexible JSON documents. |
| 5 | Gaming leaderboards + sessions | **Key-Value** (Redis) | Redis sorted sets for leaderboards, key-value for sessions with TTL. An RDBMS for persistent player accounts. |
| 6 | Hospital records       | **RDBMS**           | Strict data integrity, ACID transactions, regulatory compliance (HIPAA), audit trails, complex relationships. |
| 7 | E-commerce recommendations | **Graph DB** + **RDBMS** | Graph DB for "also bought" relationships. RDBMS for order processing and inventory. |
| 8 | Startup MVP            | **Document DB**     | Flexible schema allows rapid iteration. Can always migrate to RDBMS later when the model stabilizes. |

</details>

---

### Exercise 5: Complete Cloud Architecture

Design a cloud database architecture for a fictional **Online Education Platform**
with these requirements:

- Students can enroll in courses and submit assignments
- Instructors create courses with video lectures, quizzes, and text content
- Students receive grades and certificates
- The platform needs a discussion forum
- Live class sessions with real-time chat
- Analytics dashboard showing course completion rates
- The platform serves users in North America, Europe, and Asia

Draw (or describe) which databases you would use and why.

<details>
<summary>💡 Click to reveal solution</summary>

```
Online Education Platform — Database Architecture

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────────────────────────┐                               │
│  │  Azure SQL Database          │  WHY: ACID transactions       │
│  │  (Primary - East US)         │  for enrollments, grades,     │
│  │                              │  payments, certificates       │
│  │  Tables:                     │                               │
│  │  - Students                  │  Geo-replicated to:           │
│  │  - Instructors               │  - West Europe (read replica) │
│  │  - Courses                   │  - Southeast Asia (read)      │
│  │  - Enrollments               │                               │
│  │  - Assignments               │                               │
│  │  - Grades                    │                               │
│  │  - Payments                  │                               │
│  │  - Certificates              │                               │
│  └──────────────────────────────┘                               │
│                                                                 │
│  ┌──────────────────────────────┐                               │
│  │  Azure Cosmos DB             │  WHY: Flexible schema for     │
│  │  (Global distribution)       │  course content (videos,      │
│  │                              │  quizzes, text have different  │
│  │  Containers:                 │  structures). Global low-     │
│  │  - CourseContent             │  latency reads for content    │
│  │  - DiscussionPosts           │  delivery.                    │
│  │  - ForumThreads              │                               │
│  └──────────────────────────────┘                               │
│                                                                 │
│  ┌──────────────────────────────┐                               │
│  │  Azure Cache for Redis       │  WHY: Real-time chat,         │
│  │                              │  session management,          │
│  │  Usage:                      │  caching course catalogs,     │
│  │  - Live chat messages        │  leaderboard / progress       │
│  │  - User sessions             │  tracking.                    │
│  │  - Course catalog cache      │                               │
│  │  - Real-time notifications   │                               │
│  └──────────────────────────────┘                               │
│                                                                 │
│  ┌──────────────────────────────┐                               │
│  │  Azure Synapse Analytics     │  WHY: Analytics dashboard     │
│  │                              │  for course completion rates, │
│  │  Data:                       │  student engagement, revenue  │
│  │  - Aggregated from SQL DB    │  reports. Handles complex     │
│  │  - Course completion metrics │  analytical queries over      │
│  │  - Revenue reports           │  large datasets.              │
│  │  - Student engagement stats  │                               │
│  └──────────────────────────────┘                               │
│                                                                 │
│  ┌──────────────────────────────┐                               │
│  │  Azure Blob Storage          │  WHY: Store video lectures,   │
│  │                              │  documents, certificates      │
│  │  Containers:                 │  (PDFs), student uploads.     │
│  │  - /videos                   │  Cost-effective, scalable.    │
│  │  - /documents                │                               │
│  │  - /certificates             │                               │
│  │  - /submissions              │                               │
│  └──────────────────────────────┘                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Data Flow:
  Student enrolls → Azure SQL (ACID transaction)
  Student watches video → Blob Storage (CDN cached)
  Student posts in forum → Cosmos DB (flexible schema, global)
  Student chats in live class → Redis (real-time, ephemeral)
  Admin views analytics → Synapse (aggregated, optimized for BI)
```

</details>

---

## 20. Next Steps & Resources

### 20.1 Immediate Next Steps

```
1. PRACTICE, PRACTICE, PRACTICE
   - Rebuild the RetailDB from scratch without looking at notes
   - Solve SQL challenges on online platforms
   - Build a database for a personal project

2. LEARN BASIC SET THEORY
   - Union, Intersection, Difference
   - Cartesian Product
   - These map directly to SQL operations!

3. EXPLORE ADVANCED TOPICS
   - Window functions (ROW_NUMBER, RANK, LAG, LEAD, etc.)
   - Pivoting and unpivoting data
   - Temporal tables (system-versioned tables)
   - JSON support in SQL Server
   - Partitioning large tables
   - Advanced indexing (columnstore, full-text)
```

### 20.2 Recommended Learning Resources

| Resource                                | Type     | Focus                        |
| --------------------------------------- | -------- | ---------------------------- |
| **Microsoft Learn** (learn.microsoft.com) | Free    | Azure SQL, SQL Server, T-SQL |
| **SQLBolt** (sqlbolt.com)               | Free     | Interactive SQL tutorials     |
| **LeetCode** (SQL Problems)             | Free     | SQL practice problems         |
| **HackerRank** (SQL Track)              | Free     | SQL challenges                |
| **W3Schools SQL**                       | Free     | Quick reference               |
| **Brent Ozar's Blog**                   | Free     | SQL Server performance        |
| **SQL Server Central**                  | Free     | Community articles            |
| **"T-SQL Fundamentals"** by Itzik Ben-Gan | Book  | Deep T-SQL knowledge          |
| **"SQL Performance Explained"** by Markus Winand | Book | Index/query optimization |
| **MongoDB University**                  | Free     | MongoDB courses               |
| **Azure Free Account**                  | Free     | $200 credit + free services   |

### 20.3 Certification Paths

```
Microsoft Certifications:
├── DP-900: Azure Data Fundamentals (beginner)
├── AZ-900: Azure Fundamentals (beginner)
├── DP-300: Administering Azure SQL (intermediate)
└── DP-203: Data Engineering on Azure (advanced)

MongoDB Certification:
└── MongoDB Associate Developer

AWS Certifications:
├── AWS Cloud Practitioner (beginner)
└── AWS Database Specialty (advanced)
```

### 20.4 Practice Project Ideas

| Project                         | Skills Practiced                              |
| ------------------------------- | --------------------------------------------- |
| Library Management System       | CRUD, JOINs, stored procedures                |
| E-Commerce Store                | Complex queries, transactions, indexes         |
| Student Grade Tracker           | Aggregation, views, reports                    |
| Social Media Backend            | Graph concepts, complex joins                  |
| IoT Dashboard                   | Time-series, NoSQL concepts                   |
| Personal Finance Tracker        | Transactions, aggregation, views              |
| Inventory Management            | Stored procedures, triggers, auditing         |
| Blog / CMS                      | Document modeling, flexible schemas           |
| Real-time Chat (with Redis)     | Key-value store, sessions, pub/sub            |
| Multi-region App (with Cosmos)  | Global distribution, consistency models       |

### 20.5 Final Advice

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   "The best way to learn SQL is to write SQL."                  │
│                                                                 │
│   1. Don't just read — TYPE every example.                      │
│   2. Don't just copy — MODIFY and experiment.                   │
│   3. Don't just succeed — BREAK things and fix them.            │
│   4. Don't just learn SQL — UNDERSTAND why databases work.      │
│   5. Don't just use one database — EXPLORE the ecosystem.       │
│                                                                 │
│   The skills you've learned this week are foundational.         │
│   They will serve you in every area of software development.    │
│                                                                 │
│   Databases are everywhere:                                     │
│   Web apps, mobile apps, AI/ML, IoT, cloud, data science,      │
│   gaming, finance, healthcare, government, and more.            │
│                                                                 │
│   Keep building. Keep querying. Keep learning.                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎓 Congratulations!

You have completed the **5-Day SQL Curriculum**!

### What You Can Now Do:

- ✅ Design and create relational databases
- ✅ Write complex SQL queries with JOINs, subqueries, and CTEs
- ✅ Optimize queries with indexes and execution plans
- ✅ Build reusable stored procedures with error handling
- ✅ Understand when to use RDBMS vs NoSQL
- ✅ Set up and manage Azure SQL databases in the cloud
- ✅ Make informed decisions about database architecture

### Remember:

**Practice. Practice. Practice.**

And yes — learn basic set theory from high school math. 😉

---

> **Thank you for being a part of this course. Your journey into the world
> of databases has just begun. The possibilities are endless.**