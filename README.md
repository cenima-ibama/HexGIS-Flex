# HexGIS-Flex
Repository to hold the flex code framework.


This file contains installation and customization instructions for the HEX GIS Flex application.


=========================================================================


1 GeoServer:

 _ First, you need to have Geoserver up and running. If you do not have it installed on your system, visit: 
                                                                              http://docs.geoserver.org/latest/en/user/installation/index.html



2 PostgreSQL + PostGIS:

 _ Second, you need a PostgreSQL database with PostGIS extension enabled.
 _ Add the database to Geoserver as a new data source, and publish a PostGIS table as a new layer.
 _ For details, visit: http://docs.geoserver.org/stable/en/user/gettingstarted/postgis-quickstart/index.html 



3 Customizing your HEX GIS Flex application:

> In <root>/src/config.xml

 _ For minor layout alterations:
   . To change the app title: Change the value of the <title> element inside <userinterface>.

   . To change the app subtitle: Change the value of the <subtitle> element inside <userinterface>.

   . To change the app logotype icon: Change the value of the <logo> element inside <userinterface> with the path for a new image.


 _ For menu related alterations:
   . To include a new button to the top bar menu: Add a new <menu> element into <menus>

   . To change a menu item visibility: Alter the value of the "visible" attribute inside <menu> element (use "true" or "false")

   . To change a menu label: Alter the <menu> element value


 _ For widget related alterations:
   . To include a new widget: Add a new <widget> element into <widgets> and assign it to one of the declared menus

   . To load a widget as the application starts: Alter the value of the "preload" attribute inside <widget> element (use "true" or "false")

   . To change a widget label: Alter the value of the "label" attribute inside <widget>


 _ For link related alterations:
   . To include a new link: Add a new <link> element into <links> and assign it to one of the declared menus

   . To change a link label: Alter the value of the "label" attribute inside <link>

   . To change a link address: Alter the <link> element value


> In <root>/src/dados/camadas.xml

 _ To include a new layer (WMS or WFS) to be displayed on base map:

   . Add a new <camada> element into <camadas> and edit the value of each child element accordingly:
        - <name>: Name to be displayed by the Layer Manager Widget
		- <url>: Geoserver WMS/WFS URL
		- <type>: Layer type ("wms" or "wfs")
		- <layers>: The name of the layer to be loaded from Geoserver
		- <format>: The format the returned images must be in (e.g. "image/png")
		- <maxExtent>: The bounding box (left, bottom, right, top) of the layer maximum extension
		- <version>: Protocol version
		- <visible>: If it must be made visible once the app starts (use "true" or "false")
		- <transparent>: If the image background must be transparent or not (use "true" or "false")
        - <tiled>: Constrols whether meta-tiling must be used or not (use "true" or "false")

   
 _ To include a new group of WMS layers to be displayed on base map as a single layer:

   . Add a new <grupo> element into <camadas>
   . Add each of your WMS layers as a <camada> element inside the <grupo> element.
   . Edit the attributes values accordingly:
        - name: Name to be displayed by the Layer Manager Widget
        - visible: If the layers within the group must be made visible as the app starts (use "true" or "false")



4 Linking the application to your Geoserver: 

> Change geoserver address in the Export Widget configuration file (<root>/src/widgets/ExportWidget.xml) 



5 Linking the application to your Web Services: 

> In <root>/src/solutions/WidgetManager.mxml
 _ Change WSDL address at line 423


 > In <root>/src/widgets/componentes/ibama/feature/LineStringFeaturePanel.mxml
 _ Change WSDL address at line 620


 > In <root>/src/widgets/componentes/ibama/feature/Gallery.mxml
 _ Change WSDL address at line 220


 > In <root>/src/widgets/componentes/ibama/feature/PointFeaturePanel.mxml
 _ Change WSDL address at line 625



6 Apache Tomcat Server

_ You need to have Apache Tomcat Server up and running. For details about the installation and setup processes, visit: 
   . https://tomcat.apache.org/tomcat-7.0-doc/appdev/installation.html
   . https://tomcat.apache.org/tomcat-7.0-doc/setup.html



7 Deploying and lauching the HEX GIS Flex application:

   _ Zip the content of the bin-release folder of the application in the form of a .war file and deploy it in Apache Tomcat Webserver.
   _ Launch your web application using appropriate URL.
   _ For details, visit: http://www.tutorialspoint.com/flex/flex_deploy_application.htm


=========================================================================
