from flask import Flask, render_template, request

app = Flask(
    __name__,
    template_folder="templates", static_folder="static", static_url_path=''
)

@app.route("/")
def main():
    return render_template("index.html")

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
