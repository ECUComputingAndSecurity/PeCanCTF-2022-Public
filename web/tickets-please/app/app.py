from flask import Flask, request, render_template, url_for, make_response
import json, jwt, time, os, random, sqlite3

app = Flask(
    __name__, 
    template_folder="templates",
    static_folder="static",
    static_url_path=""
    )
key = "mylittlesecret"


@app.route("/get_ticket", methods=['GET'])
def get_token():
    sesh_token = jwt.encode({'conductor': False, 'now': time.time()}, key, algorithm='HS256')
    #r = make_response(render_template("ticket.html", token=sesh_token.decode("utf-8")))
    r = make_response(render_template("ticket.html", token=sesh_token))
    r.set_cookie('jwt', sesh_token)
    return r


@app.route("/conductor_seat", methods=['POST', 'GET'])
def get_flag():
  try:
    payload = jwt.decode(request.cookies.get('jwt'), key, algorithms=['HS256'])
    if payload['conductor']:
        return render_template("conductor.html", flag="pecan{bRu73f0rc3-w34k-K3yz}")
    else:
        return render_template("bruh.html", image="angry.gif", msg="Hey! You aren't the train conductor!")
  except:
      return render_template("bruh.html", msg=":^(")


@app.route("/train", methods=['GET'])
def train():
    try:
        if 'jwt' in request.cookies:
            return render_template("train.html")
        else:
            return render_template("bruh.html", msg="You need a ticket to get on the train!")
    except:
        return render_template("bruh.html", msg=":^(")


@app.route("/", methods=["GET", "POST"])
def main():
    con = sqlite3.connect("hints.db")
    con.row_factory = sqlite3.Row
    c = con.cursor()
    c.execute("SELECT hint from hints ORDER BY RANDOM() LIMIT 1;")
    out = c.fetchall()
    if request.method == "POST":
        return render_template("index.html", hint=out)
    else:
        return render_template("index.html")


if __name__ == "__main__":
  app.run(host="0.0.0.0", port=5000)


