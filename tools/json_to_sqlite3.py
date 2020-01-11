import sqlite3
import json
from time import time
from random import shuffle

def create_connection(db_file):
    """ create a database connection to a SQLite database """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(e)

def load_json():
    with open('n5_to_n1.json', encoding='utf8') as json_file:
        return json.load(json_file)

if __name__ == '__main__':
    wordList = load_json()
    conn = create_connection(r"sqlite3.db")
    conn.cursor()
    conn.execute('''
            CREATE TABLE IF NOT EXISTS vocabs
            (
                word TEXT,
                meaning TEXT,
                hiragana TEXT,
                romaji TEXT,
                level INTEGER,
                created_time INTEGER,
                is_user_defined INTEGER
            )
    ''')
    
    createdTime = round(time())
    shuffle(wordList)

    for d in wordList:
        word = d['word']
        meaning = d['meaning']
        hiragana = d['hiragana']
        romaji = d['romaji']
        level = d['level']
        conn.execute(
            "INSERT INTO vocabs VALUES (?,?,?,?,?,?,?)",
            (word, meaning, hiragana, romaji, level, createdTime, 0)    
        )
    
    conn.commit()

    if conn:
        conn.close()
    