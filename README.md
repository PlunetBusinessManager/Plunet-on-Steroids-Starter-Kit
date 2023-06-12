# Plunet-on-Steroids-Starter-Kit
Starter Kit for JS Customization and AutoHotKey

## Introduction
Below I will outline all the steps required to get your first button into your plunet instance Order details page along with the files you need to do it.

The corresponding discussion can be found at:
https://community.plunet.com/t/h7h4bpx/plunet-on-steroids-a-getting-started-guide-with-a-sample-tool

The presentation from the Plunet Summit can be found here:
https://github.com/PlunetBusinessManager/Plunet-on-Steroids-Starter-Kit/blob/main/PluSum23_IanBarrow.pptx

There are 5 components used in this setup that can be found in the zip file.
Please note all my experimenting is done using Firefox browser.
Both the AHK scripts below should be compiled into exe using AutoHotKey version 1.1.36.
https://www.autohotkey.com/ select Download v.1. (deprecated)
Although version 2.0 is out, I have found some of the simple functionality I use has been dropped, so for this demo i've stuck with what I know.

## First component: custom.js
Add the custom JS content to Plunet:
https://community.plunet.com/t/35hn5tk/hidden-gem-integrating-your-own-javascript-code-into-plunet

The custom.js file attached here is the same as in his article, with some additional functionality to add the "Add due Dates" button to the order details page.
If you don't want Sufian's customer page buttons, then change the line:
`add_buttonsCustomer();` to  `//add_buttonsCustomer();`

This will stop them being added.

## Second component:  protocols.reg
This file contains all the lines that can be added to the registry to enable a button click in the browser to launch an executable.
you can change the line 12 to a path that is ideally accessable to your internal team.
e.g. change:

    @="\"C:\\plunetbutton\\ToolRedirect_UUIDvalidator.exe\" \"%1\""

to

    @="\"P:\\projectmanagers\\plunetbutton\\ToolRedirect_UUIDvalidator.exe\" \"%1\""

## Third component: data.txt
This  small file contains your config information for your plunet API.
It has 4 lines
- Your url to your plunet api e.g. `"plunetconversis:443"`
- The security of your plunet instance `https://` or `http://`
- Your API users username
- Your API users password
this should sit next to the exes compiled below.

## Fourth component: ToolRedirect_UUIDvalidator.ahk
When compiled to an executable this handles the information received via the protocol.

It then closes the tab that the button just opened in the browser
(any suggestions on how to avoid the tab being opened in the custom.js do tell me)

After that it will then confirm existing or generate a new UUID.

Split the information sent to the the exe into order name and command.

Then launch the exe that matches the command if the if statements.

## Fifth component: SetItemDueDates_demo.ahk
This is my sample command. It's used to set due dates in an item in batches.

Once compiled into and exe select some items, a date and time and click a number button to set that batch of items with the selected due date.

Once yor happy click submit to push the info to Plunet.

you'll need to navigate away from the order details page to the job details page or some other location while it updates the info via the API.

## Closing comments
Additional commands can be added by duplicating the below in the ToolRedirect files and changing the labels  

    if command = SetItemDueDates_demo
      {
           run "SetItemDueDates_demo.exe" "%UUID%" "%ordernumber%"
      }

All testing was performed on Plunet v 9.7.5

## License
Distributed under the MIT License. See LICENSE for more information.
