from flask import Flask, render_template, request, url_for
import sqlite3

app = Flask(
    __name__,
    template_folder="templates", static_folder="static", static_url_path=""
)


def sqlcrap():
    un = request.form['uname']
    pw = request.form['pass']
    login = "login.html"

    if un.lower() == "carlos":
        flag = "pecan{Gauntl3t_lvl_1_!!!}"
        sqli_filter = []
    elif un.lower() == "admin":
        flag = "pecan{u_so-smarttt-so_cl3v3rrrrr}"
        sqli_filter = ["OR", "1"]
    elif un.lower() == "superadmin":
        flag = "pecan{I_have_ran_out_of_flag_name_ideas}"
        sqli_filter = ["OR", "1", "or", "="]
    else:
        return render_template(login, msg="Not a user!!!")

    for i in sqli_filter:
        if i in pw:
            return render_template(login, msg="detected malicious characters")
    if " " in pw:
        return render_template(login, msg="whitespace detected")
    
    con = sqlite3.connect("users.db")
    con.row_factory = sqlite3.Row
    c = con.cursor() 
    
    c.execute("SELECT * FROM creds WHERE username='%s' AND password='%s';" % (un, pw))
    if not c.fetchone():
        return render_template(login, msg="Nope!")
    else:
        return render_template("flag.html", flag=flag)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/login", methods=["GET","POST"])
def login():
    if request.method == "POST":
        try:
            filters = []
            return sqlcrap()
        except sqlite3.Error as e:
            return render_template("login.html", msg="error: ", error=e)
    else:
        return render_template("login.html")

@app.route("/robots.txt")
def robots():
    return render_template("robots.txt")

@app.route("/flag")
def fake_flag():
    return render_template("haha.html")

@app.route("/hint")
def hint():
    return render_template("hint.html")

@app.route("/filters")
def filterz():
    return render_template("filter.html")


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')

