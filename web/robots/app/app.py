from flask import Flask, render_template, request

app = Flask(
    __name__,
    template_folder="templates", static_folder="static", static_url_path=''
)

@app.route("/")
def main():
    return render_template("index.html")

@app.route("/blahblahblah/")
@app.route("/boring/")
@app.route("/nothing/")
@app.route("/junk/")
def junk():
    return render_template("bruh.html")

@app.route("/tokens/")
def flag():
    return render_template("flag.html", flag="pecan{1ts_bC-Th3y_4re_andr01dz.ha.ha}")

@app.route("/robots.txt")
def robots():
    return render_template("robots.txt")

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
