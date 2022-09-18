from flask import Flask, render_template, request
import sqlite3

app = Flask(
    __name__,
    template_folder="templates", static_folder="static", static_url_path=''
)

@app.route("/", methods=["POST", "GET"])
def main():
    if request.method == "POST":
        try:
            category = request.form.get("query")
            if category == "secret":
                return render_template("index.html", image="emoj.png")
            con = sqlite3.connect("facts.db")
            con.row_factory = sqlite3.Row
            c = con.cursor()
            c.execute("SELECT * FROM facts WHERE category='%s';" % category)
            rows = c.fetchall()
            return render_template("index.html", rows = rows, category = category)
        except sqlite3.Error as e:
            return render_template("index.html", msg="error: ", error=e)
    else:
        return render_template("index.html")

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
