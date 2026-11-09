<?php

$visitor_email = $_POST['vMail'];
$visitor_name = $_POST['vName'];
$message_subj = $_POST['vSubj'];
$visitor_msg = $_POST['vMessage'];
$visitor_company = $_POST['vCompany'];
$mail_to = $_POST['vTo'];
$from = "Proiam Registration Form";
$subject = "{$message_subj}";
$headers = "Content-Type: text/html; charset=\"us-ascii\";\r\n";
$headers .= "From: {$visitor_name} ({$visitor_company}) <{$visitor_email}>; \r\n"; 
$message = <<<EOF
<br/>
<b>Mail sent from: </b> {$from}<br/><br/>

---------- Visitor Details -------------<br/><br/>

<b>Full Name:</b> {$visitor_name}<br/>
<b>E-mail:</b> {$visitor_email}<br/>
<b>Company:</b> {$visitor_company}<br/>
<b>C IP Address:</b> {$_SERVER['HTTP_CLIENT_IP']}<br/>
<b>F IP Address:</b> {$_SERVER['HTTP_X_FORWARDED_FOR']}<br/>
<b>R IP Address:</b> {$_SERVER['REMOTE_ADDR']}<br/>
<b>Agent:</b> {$_SERVER['HTTP_USER_AGENT']}<br/><br/>

----------- Visitor Wrote -------------<br/><br/>

<b>Subject / Title:</b> {$message_subj}<br/>
<b>Message:</b> {$visitor_msg}<br/><br/>

EOF;

$OK = mail ($mail_to, $subject, $message, $headers);
	
if(eregi("^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,3})$", $visitor_email)) {
	if ($OK) {
		echo 'sent="OK"';
	} else 	{
		echo 'sent="Error sending mail."';
	}
} else {
  echo 'sent="Invalid email address."';
}

?>
