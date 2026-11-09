<?php 
// you send messages back to the client 
// and then move the file from php's temporary upload directory to your local directory 
// Filedata is the default name used in uploading 
echo "\nReceiving upload...\n"; 
echo "temporary file name = " . $_FILES['Filedata']['tmp_name']."\n"; 
echo "file name = " . $_FILES['Filedata']['name']."\n"; 
echo "file size = " . $_FILES['Filedata']['size']."\n"; 
echo "attempting to move file to " . "../upload/" . $_FILES['Filedata']['name'] . "\n"; 
move_uploaded_file($_FILES['Filedata']['tmp_name'], "../upload/".$_FILES['Filedata']['name']); 
echo "file moved\n"; ?>
