<?php
error_reporting(0);
$file = "messages.php";

if (isset($_GET['file']))
	$file = $_GET['file'];
	$file = str_replace("../","", $file);

$fullPath = '/var/www/html/page/'.$file;

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Dashboard</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Raleway">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<style>
body,h1,p {font-family: "Raleway", sans-serif; text-align: center;}
* {
  box-sizing: border-box;
}
body{
    background-image: url('/static/images/bg.gif');
    background-repeat: no-repeat;
    background-attachment: fixed;
    background-size: cover;
}
</style>
<body>

	<body>
    <div id="wrapper">
        <!-- Page Content -->
        <div id="page-content-wrapper">

            <div class="container-fluid">
                <div class="row text-right mb-4">
	                <div class="col">
	                    <select class="custom-select" id="changeFile">
	                    	<?php
                                echo "<option value='$file' selected='true'>$file</option>";
                                $files = array("messages.php", "logs.php");
                                foreach ($files as $page){
                                    if($page != $file){
                                    echo "<option value='$page'>$page</option>";
                                    }
                                }
	                    	?>
						</select>  
	                </div>    
	            </div>

                <div class="manage-box">
                	<?php include_once($fullPath); ?>
                </div>
            </div>
        </div>
        <!-- /#page-content-wrapper -->

    </div>
</body>
<script src="/static/vendor/jquery/jquery-3.2.1.min.js"></script>
<script src="/static/js/dashboard.js"></script>
</html>
