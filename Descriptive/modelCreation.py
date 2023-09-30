# Import libraries
import sqlite3

# Define the SQLite database file name
database_file = "favorita.db"

# Create a connection to the database
connection = sqlite3.connect(database_file)
cursor = connection.cursor()

# Define SQL statements to create six tables
create_holidays_events = """
CREATE TABLE IF NOT EXISTS holidays_events (
    date DATE,
    type VARCHAR(15),
    locale VARCHAR(10),
    locale_name VARCHAR(55),
    description VARCHAR(255),
    transferred VARCHAR(5)
);
"""

create_oil = """
CREATE TABLE IF NOT EXISTS oil (
    date DATE,
    dcoilwtico FLOAT
);
"""

create_stores = """
CREATE TABLE IF NOT EXISTS stores (
    store_nbr INTEGER,
    city VARCHAR(55),
    state VARCHAR(105),
    type VARCHAR(2),
    cluster INTEGER
);
"""

create_test = """
CREATE TABLE IF NOT EXISTS test (
    id INTEGER,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(75),
    onpromotion INTEGER
);
"""

create_train = """
CREATE TABLE IF NOT EXISTS train (
    id INTEGER,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(75),
    sales FLOAT,
    onpromotion INTEGER
);
"""

create_transactions = """
CREATE TABLE IF NOT EXISTS transactions (
    date DATE,
    store_nbr INTEGER,
    transactions INTEGER
);
"""

# Execute the SQL statements to create the tables
cursor.execute(create_holidays_events)
cursor.execute(create_oil)
cursor.execute(create_stores)
cursor.execute(create_test)
cursor.execute(create_train)
cursor.execute(create_transactions)

# Commit the changes and close the connection
connection.commit()
connection.close()

print("Favorita model created successfully.")
