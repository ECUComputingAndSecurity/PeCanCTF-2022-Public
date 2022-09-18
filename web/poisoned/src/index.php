<!DOCTYPE html>
<html>
<head>
<title>Poisoned</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Raleway">
<style>
body,h1,p {font-family: "Raleway", sans-serif; text-align: center;}
* {
  box-sizing: border-box;
}

.column {
  float: left;
  width: 33.33%;
  padding: px;
}

/* Clearfix (clear floats) */
.row::after {
  content: "";
  clear: both;
  display: table;
}
</style>
</head>
<h1>
    These are some Poisonous Plants!
</h1>
<body>
  <!-- Don't forget to make /dashboard.php inaccessible -->
    <div class="row">
      <div class="column">
        <figure>
          <img src="/static/images/manchineel.jpg" alt="Machineel" style="width:100%">
          <figcaption>Manchineel</figcaption>
        </figure>
      </div>
      <div class="column">
        <figure>
          <img src="/static/images/iris.jpeg" alt="Iris" style="width:100%">
          <figcaption>Iris</figcaption>
        </figure>
      </div>
      <div class="column">
        <figure>
          <img src="/static/images/poisonous_belladonna.jpeg" alt="Poisonous Belladonna" style="width:100%">
          <figcaption>Poisonous Belladonna</figcaption>
        </figure>
      </div>
    </div>
    <div class="row">
      <div class="column">
        <figure>
          <img src="/static/images/wild_poinsettia.jpg" alt="Wild Poinsettia" style="width:100%">
          <figcaption>Wild Poinsettia</figcaption>
        </figure>
      </div>
      <div class="column">
        <figure>
          <img src="/static/images/elderberry.jpg" alt="Elderberry" style="width:100%">
          <figcaption>Elderberry</figcaption>
        </figure>
      </div>
      <div class="column">
        <figure>
          <img src="/static/images/monkshood.jpg" alt="Monkshood" style="width:100%">
          <figcaption>Monkshood</figcaption>
        </figure>
      </div>
    </div> 
</body>
</html>