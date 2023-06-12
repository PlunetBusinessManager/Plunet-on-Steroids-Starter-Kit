function get_customer_id() {
	try{
		var customer_id = document.querySelectorAll('[Name="TokenPKID"]')[0].value;
		} catch {
		customer_id = "None"
		};
	try{
		var customer_name = document.getElementById('+inp+Nachname').value;
	} catch {
		customer_name = "None"
	};
	try{
		var customer_email = document.getElementById('+inp+AjaxHandlerZusaetzlCC1KommuEmail').value
		var position = customer_email.indexOf("@");
		var customer_domain = customer_email.substring(position+1);
	} catch {
		customer_domain = "None"
	};
    return [customer_id, customer_name, customer_domain];
}

function GetOrderQuoteNumber() {
        var OrderQuoteNumber;
        var parentElement;
        var textToFind;

        if (window.location.pathname.includes("auftrag_job.jsp")) {
            parentElement = "#secondSubMenuBarHead";
            textToFind = 'O-';
        }
        else if (window.location.pathname.includes("auftrag_allgemeinauftrag.jsp")) {
            parentElement = "#secondSubMenuBarHead";
            textToFind = 'O-';
        }
        else if (window.location.pathname.includes("angebot_job.jsp")) {
            parentElement = "#secondSubMenuBarHead";
            textToFind = 'Q-';
        }
        else if (window.location.pathname.includes("angebot.jsp")) {
            parentElement = "#secondSubMenuBarHead";
            textToFind = 'Q-';
        }
        else {
            return "";
        }

        OrderQuoteNumber = $(parentElement).find("span").filter(function () { return ($(this).clone().children().remove().end().text().indexOf(textToFind) > -1) }).eq(0).text();

        return OrderQuoteNumber;
    }


function add_buttonsCustomer() {
	var customer_array = get_customer_id();
	// creating the URLEncoded Strings for the buttons
	var search_url_helpdesk = encodeURI('https://my.ticketsystem.com//issues/?jql=Organizations="'+customer_array[1]+'"');
	var search_url_jira = encodeURI('https://www.jira.com/issues/?jql=text ~ "'+customer_array[1]+'"');
	var search_url_hubspot = encodeURI('https://blabla.myhubspot.com/organizations?globalSearchQuery='+customer_array[2]);
	// find all the large sections on the site (ContentBoxes)
	const content_boxes = document.getElementsByClassName("ContentBox ContentBox3Spalten ContentBoxWhite");	
	// find all the columns in the first large Section
	const columns = content_boxes[0].getElementsByClassName("ContentBoxContainer");		
	// find all the smaller elements the right column
	var content_container = columns[2].getElementsByClassName("ContentBoxContent");
	// create a new Div for the Button and set the buttons
	var button_html = document.createElement("div");
	button_html.innerHTML = `<button type="button" class="btn btncol-primary ng-isolate-scope" onclick=window.open("${search_url_hubspot}")>
							 <span>Hubspot Search</span>
							 </button>&nbsp;
							 <button type="button" class="btn btncol-primary" ng-isolate-scope onclick=window.open("${search_url_helpdesk}")>
							 <span>Helpdesk Tickets</span>
							 </button>&nbsp;
							 <button type="button" class="btn btncol-primary" ng-isolate-scope onclick=window.open("${search_url_jira}")>
							 <span>JIRA Issues</span>
							 </button>&nbsp;
							 <button type="button" class="btn btncol-primary" ng-isolate-scope onclick=window.open("https://app.powerbi.com")>
							 <span>PowerBI</span>
							 </button>&nbsp;
							 <p>`
	// add the button before the first element in the right column
	columns[2].insertBefore(button_html, content_container[0]);
	};


function add_buttonsOrder() {
	// create a new Div for the Button and set the buttons
	var button_html = document.createElement("div");
	button_html.innerHTML = `<button type="button" class="btn btncol-primary ng-isolate-scope" onclick=runbutton('plunetbutton://${mOrderQuoteNumber}|SetItemDueDates_demo')>
							 <span>Set Due Dates</span>
							 </button>&nbsp;
							 <!--<a class="lnk lnkcol-primary" aria-label="SetItemDueDates_demo" href="plunetbutton://${mOrderQuoteNumber}|SetItemDueDates_demo"> test</a>-->
							 <p>`
	//set the lcoation to add the buttons after
	var orderbtnlocation = $('#MenuLeisteInput_IDY2').parent().siblings('.ContentBoxContainer').find('.ContentBoxHeader');
    $(button_html.innerHTML).insertAfter(orderbtnlocation);

	};

function runbutton(buttonpath) {
	window.open(buttonpath);
}

// this should only run on the detail customer pages
document.addEventListener("DOMContentLoaded", function(event) { 
	mOrderQuoteNumber = GetOrderQuoteNumber();
	if (window.location.pathname.includes('partner_kunde.jsp')) { // for the page
		if (document.getElementById('MenuLeiste_IDY2')) { //the Search Page doesnt have a Menuleiste IDY2
			add_buttonsCustomer();
		};
	};
	// this should only run on the Order details  pages
	if (window.location.pathname.includes('auftrag_allgemeinauftrag.jsp')) { // for the page
		if (document.getElementById('MenuLeiste_IDY2')) { //the Search Page doesnt have a Menuleiste IDY2
			add_buttonsOrder();
			//alert(mOrderQuoteNumber);
		};
	};
});
