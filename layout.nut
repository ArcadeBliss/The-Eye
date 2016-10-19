////////////////////////////////////////////////////////////////////////////////////////////////////////
// The Eye: Designed by verion / coded by ArcadeBliss
// credits to omegaman for the wheel conveyour values
////////////////////////////////////////////////////////////////////////////////////////////////////////

/* 

ToDo
- Determine user settings i.e. number of slots in the wheel / artwork to be used
- Turn off game sounds and use a looping low level hum
- animate the eye to blink when changing filters are when first opening

ChangeLog:

2016-09-19: Initial Draft
- Created Aspect Aware Code for the layout (current set to automatic). The code is based upon the size of the original PSD file used to design the layout.
- Created a function to auto create a spinwheel based upon the following information: arc of a circle in degrees, radius in pixels, alpha settings for artwork, scaling settings for artwork, 
- created animation for the eye's inner and outer ring

*/

	class UserConfig {
	   </ label="Select BG art", help="Blur enables art for all consoles; otherwise choose blue, retro, black or scrHer for bg", options="blur,blue,retro,black,scrHer", order=1 /> enable_bg="blur";
	   </ label="Select cab skin", help="Select a cab skin image", options="robo,moon", order=2 /> enable_cab="robo";
	   </ label="Select spinwheel art", help="The artwork to spin", options="marquee, wheel", order=3 /> orbit_art="wheel";
	   </ label="Transition Time", help="Time in milliseconds for wheel spin.", order=4 /> transition_ms="35";
	   </ label="Select listbox, wheel, vert_wheel", help="Select wheel type or listbox", options="listbox, wheel, vert_wheel", order=5 /> enable_list_type="wheel";
	   </ label="Enable snap bloom shader effect", help="Bloom effect uses shader", options="Yes,No", order=6 /> enable_bloom="No";
	   </ label="Enable crt shader effect", help="CRT effect uses shader", options="Yes,No", order=7 /> enable_crt="No";
	   </ label="Enable random text colors", help=" Select random text colors.", options="yes,no", order=8 /> enable_colors="yes";
	   </ label="Enable system logos", help="Select system logos", options="Yes,No", order=9 /> enable_slogos="Yes";
	   </ label="Enable MFR game logos", help="Select game logos", options="Yes,No", order=10 /> enable_mlogos="Yes";
	   </ label="Enable game marquees", help="Show game marquees", options="Yes,No", order=11 /> enable_marquee="Yes";
	   </ label="Enable lighted marquee effect", help="show lighted Marquee", options="Yes,No", order=12 /> enable_Lmarquee="No";
	   </ label="Select pointer", help="Select animated pointer", options="rocket,hand,none", order=13 /> enable_pointer="rocket";
	   </ label="Enable text frame", help="Show text frame", options="yes,no", order=14 /> enable_frame="yes";
	   </ label="Enble background overlay", help="Select overlay effect; options are masking, scanlines, aperture", options="mask,scanlines,aperture,none", order=15 /> enable_overlay="mask";
	   </ label="Monitor static effect", help="Show static effect when snap is null", options="yes,no", order=16 /> enable_static="yes";
	}

// Debuging --------------------------------------- START

	local counter = 0;
	function debug(source)
	{
		print(counter + ": FROM: "+ source + "\n");
		counter++;
	}
	// fe.layout.width = 640;
	// fe.layout.height = 480;
	// fe.layout.preserve_aspect_ratio = true;

// Debuging --------------------------------------- END

// load modules ----------------------------------- START
	fe.load_module("fade");
	fe.load_module( "animate" );
	fe.load_module( "conveyor" );
// load modules ----------------------------------- END

// Layout Variables ------------------------------- START

	// load display options
	local display_options = fe.get_config();
	
	// Screen Aspect Object positioning helpers
	const PSD_WIDTH = 1920;			   	// width of the orignal PSD design
	const PSD_HEIGHT = 1356;			// height of the orignal PSD design
	local viewportW = null; 	  	 	// resized width of the orignal PSD Layout design
	local viewportH = null;	       		// resized height of the original PSD Layout design
	local offset_x = null;				// the offset to use when positioning objects on the x axis
	local offset_y = null;				// the offset to use when positioning objects on the y axis
	local scaling_factor = null; 	 	// determine haw much to scale images according to the resized viewport
	local aspect_settings = null;		// give the found aspect ratio a name
	local aspect = null;				// determine the current screen aspect ratio
	local scrW = fe.layout.width;	 	//	current monitor width resolution
	local scrH = fe.layout.height; 		// current monitor height resolution
	local psdW_2_scrW =	scrW.tofloat() / PSD_WIDTH 					// shortcuts
	local psdH_2_scrH = PSD_WIDTH * scrH.tofloat() / PSD_HEIGHT;	// shortcuts
	
	// Spinwheel Variables
	local num_arts = 12;		// total number of artwork in the spinwheel
	local results = null;		// table holding the spinwheel settings
	local wheel_entries = [];	// ConveyorSlot array to hold spinwheel slot info
	local sw_settings = {		// used as input to autogenerate the values needed for the spinwheel
		sw_size 	= null,		// shape of the spinwheel circle in degrees
		sw_radius = null,       // radius of the spinwheel in pixels
		sw_center = null,       // a squirrel table with the spinwheel's center coordinate {X=0, Y=0}
		sw_alpha 	= null,     // array with the alpha settings in the formate [lowest alpha, highest alpha, alpha selected item]
		sw_art		= null,		// table with the spinwheel art width and height {width = xxx, height = xxx},
		sw_art_scaling = null,	// array scaleing factor to use for spinwheel art. [lowest scaling, highest scaling, scaling of the selected item]
	}
	
	// Aspect Ratio settings
	local scr16x10 = {};	// Settings for 16x10 screen aspect ratio					
	local scr4x3 = {};		// Settings for 4x3 screen aspect ratio					
	local scr5x4 = {};		// Settings for 5x4 screen aspect ratio					
	local scr3x4 = {};		// Settings for 3x4 screen aspect ratio	
	local scr16x9 = {        // Settings for 16x9 screen aspect ratio    		
		viewportH = PSD_HEIGHT * psdW_2_scrW,
		viewportW = scrW,
		scaling_factor =  psdW_2_scrW,
		offset_y = PSD_HEIGHT * psdW_2_scrW * 0.203539823 / 2 * -1,
		sw_radius = PSD_HEIGHT * psdW_2_scrW *0.6,
		sw_center = {X = scrW + scrW * 0.1822, Y = PSD_HEIGHT * psdW_2_scrW * 0.4},
		sw_art = {width = scrW*0.3125, height = scrH*0.1953},
		sw_art_scaling = [0.20,0.40,1]
	};				
	local scr_default = {	// default aspect ratio: 4x3 layout      		
		// Layout Settings
		viewportW = psdH_2_scrH,
		viewportH = scrH,
		scaling_factor = scrH.tofloat() /  PSD_HEIGHT,
		offset_x = 0,
		offset_y = 0,
		
		// Spinwheel Settings 
		sw_size = 180,
		sw_radius = scrH,
		sw_center = {X=psdH_2_scrH + psdH_2_scrH * 0.4, Y = scrH * 0.5 - scrH * 0.03},
		sw_alpha = [60, 100, 255],
		sw_art = {width = scrW * 0.5, height = scrH * 0.1966},
		sw_art_scaling = [0.20,0.40,0.80]
	};
	local aspects = {		//list of all configured aspect ratios					
		"1.77865" 	: scr16x9,
		"1.77778" 	: scr16x9,
		"1.6"		: scr16x10,
		"1.33333" 	: scr4x3,
		"1.25" 		: scr5x4,
		"0.75" 		: scr3x4
	}
	
	/* The orginal PSD layout is 1920x1356. This allows
	multiple aspects from one layout. These variables are used to
	resize the original PSD layout if the screen is smaller than PSD
	and calculate the offset to use for the	positioning of objects
	based upon the screen`s aspect ratio */
	
	aspect = (scrW / scrH.tofloat());
	aspect = aspect.tostring();
	aspect_settings = aspects[aspect];
	aspect_settings.setdelegate(scr_default);
	viewportH = aspect_settings["viewportH"];
	viewportW = aspect_settings["viewportW"];
	scaling_factor = aspect_settings["scaling_factor"];
	offset_x = aspect_settings["offset_x"];
	offset_y = aspect_settings["offset_y"];

	/* map current config to the spin wheel settings*/
	sw_settings["sw_size"] = aspect_settings["sw_size"];
	sw_settings["sw_radius"] = aspect_settings["sw_radius"];
	sw_settings["sw_center"] = aspect_settings["sw_center"];
	sw_settings["sw_alpha"] = aspect_settings["sw_alpha"];
	sw_settings["sw_art"] = aspect_settings["sw_art"];
	sw_settings["sw_art_scaling"] = aspect_settings["sw_art_scaling"];

	// Layout Variables ------------------------------- END

// Setup Layout Classes --------------------------- START

	//	Spinwhell slot class to hold the wheel entries
	class WheelEntry extends ConveyorSlot
	{

		// wheel settings for the curved wheel
		wheel_x = null;
		wheel_y = null;
		wheel_w = null;
		wheel_a = null;
		wheel_h = null;
		wheel_r = null;

		constructor()
		{
			base.constructor( fe.add_artwork( "logo" ) );
		}

		function on_progress( progress, var )
		{
			local p = progress / 0.1;
			local slot = p.tointeger();
			p -= slot;

			slot++;

			if ( slot < 0 ) slot=0;
			if ( slot >=10 ) slot=10;

			m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
			m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
			m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
			m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
			m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
			m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );

		}
	};

// Setup Layout Classes --------------------------- END

// Setup Layout options, functions and helpers ---- START
	

	function createSpinwheelStops( spinwheel_config )
	{
	/* create spin wheel stops based 
	upon calculation points on an arc */	
		local size = spinwheel_config["sw_size"]			// the size of the circle in degrees
		local points = 12 									// the amount of stops the spinwheel will have constant of 12
		local radius = spinwheel_config["sw_radius"]		// radius in pixels the circle should be
		local center = spinwheel_config["sw_center"]		// a squirrel table with the circle's center coordinate {X=0, Y=0}
		local alpha	= spinwheel_config["sw_alpha"]			// 
		local artsize =	spinwheel_config["sw_art"]			// 
		local artscale = spinwheel_config["sw_art_scaling"]	// 
		local angle = null;										// angle of the current coordinate in radians
		local newX = null;										// X coordinate of the current coordinate
		local newY = null;										// Y coordinate of the current coordinate
		local results = {x=[],y=[],r=[],a=[],w=[],h=[]};		// table containing all of the computed coordinates and angles
		local angle_slice = (size * PI / 180) / points; 		// create equal stops along the spinwheel
		local alpha_slice = (alpha[1] - alpha[0]) / (points/2-1);
		local artscale_slice = (artscale[1] - artscale[0]) / (points/2-1);
		local test = null;
		
		
		for (local i = 0; i < points; i++)
		{
			angle = angle_slice * i - 1.5708;
			newX = center.X - radius * cos(angle);
			newY = center.Y + radius * sin(angle);
			
			results.x.push(newX);
			results.y.push(newY);
			results.r.push((angle * 180 / PI) *-1);
			// test = fe.add_text("",newX.tointeger(),newY.tointeger(),300,10);
			// test.rotation = (angle * 180 / PI) *-1;
			// test.msg = "X:" + newX + " Y:" + newY + " Loop:" + i;
			
			if (i < points/2)
			{
				/* load the alpha channel, width, and height
				of the wheel image from lowest configured value 
				to heighest */
				results.a.push(i*alpha_slice + alpha[0]);
				results.w.push(((i*artscale_slice)+artscale[0])*artsize["width"]);
				results.h.push(((i*artscale_slice)+artscale[0])*artsize["height"]);
				
			} else if (i > points/2) {
				/* load the alpha channel, width, and height
				of the wheel image from highest configured value 
				to lowest */
				results.a.push((points - i)*alpha_slice + alpha[0]);
				results.w.push((((points - i)*artscale_slice)+ artscale[0])*artsize["width"]);
				results.h.push((((points - i)*artscale_slice)+ artscale[0])*artsize["height"]);
			} else {
				/* load the configured selection value for the artwort alpha channel,
				width, and height */	
				results.a.push(alpha[2]);
				results.w.push(artscale[2]*artsize["width"]);
				results.h.push(artscale[2]*artsize["height"]);
				
				results.x[i]= results.x[i] - results.w[i]/4;	// center the selected item in the spinwheel
				results.y[i]= results.y[i] - results.h[i]/3;	// center the selected item in the spinwheel
			}
			
		}
			
		return results;
		
	}
		
// Setup Layout options, functions and helpers ---- END


// ----------------------------------------
//             Layout Theme Objects
// ----------------------------------------

	//
	//	Load fan art
	//
	local fan_art = fe.add_artwork(
		"fanart",
		0 + offset_x,
		0 + offset_y,
		viewportW,
		viewportH
	);
	fan_art.preserve_aspect_ratio = false;


	//
	//	Load snap as a sphere
	//

	local video = fe.add_artwork("snap",
		132 * scaling_factor + offset_x,
		240 * scaling_factor + offset_y,
		878 * scaling_factor,
		877 * scaling_factor
	);

	local sh = fe.add_shader( Shader.VertexAndFragment, "assets/shaders/sphere.vert", "assets/shaders/sphere.frag" );
	sh.set_param( "bkg_color", 0, 0, 0 ,0 );
	sh.set_param( "time", 0.5 );
	sh.set_texture_param("tex0");
	video.shader = sh;

	//
	//	Load snap as a disc
	//
	sh = fe.add_shader( Shader.VertexAndFragment, "assets/shaders/circle.vert", "assets/shaders/circle.frag" );
	sh.set_param( "border_size", 0.01 )
	sh.set_param( "disc_radius", 0.5 )
	sh.set_param( "disc_color", 0, 0, 0 ,0 )
	sh.set_param( "disc_center", 0.5, 0.5 )
	sh.set_texture_param("tex0");
	video.shader = sh;

	//
	//	Load eye backdrop
	//
	local backdrop = fe.add_image(
		"assets/uielements/backdrop.png",
		0 + offset_x,
		0 + offset_y,
		viewportW,
		viewportH
	);

	//
	//	Load inner ring backdrop and animate it
	//
	local inner_ring = fe.add_image(
		"assets/uielements/INNER-ring.png",
		132 * scaling_factor + offset_x,
		240 * scaling_factor + offset_y,
		878 * scaling_factor,
		877 * scaling_factor
	);
	 animation.add( PropertyAnimation( inner_ring,
			 {
				 time = 280000,
			 	 loop = true,
				 property = "rotation"
				 end = "+360"
			 } ) );

	//
	//	Load outer ring backdrop
	//
	local outer_ring = fe.add_image(
		"assets/uielements/OUTER-ring.png",
		70 * scaling_factor + offset_x,
		170 * scaling_factor + offset_y,
		1028 * scaling_factor,
		1013 * scaling_factor
	);
	animation.add( PropertyAnimation( outer_ring,
			{
				time = 140000,
				loop = true,
				property = "rotation"
				end = "-360"
			} ) );

	//
	//	Load the spinwheel
	//
	results = createSpinwheelStops(sw_settings);

	for ( local i=0; i<num_arts/2; i++ )
	{
		wheel_entries.push( WheelEntry() );

		wheel_entries[i].wheel_x = results["x"];
		wheel_entries[i].wheel_y = results["y"];
		wheel_entries[i].wheel_w = results["w"];
		wheel_entries[i].wheel_a = results["a"];
		wheel_entries[i].wheel_h = results["h"];
		wheel_entries[i].wheel_r = results["r"];
	}

	local remaining = num_arts - wheel_entries.len();

	// we do it this way so that the last wheelentry created is the middle one showing the current
	// selection (putting it at the top of the draw order)

	for ( local i=0; i<remaining; i++ )
	{
		wheel_entries.insert( num_arts/2, WheelEntry() );
		wheel_entries[num_arts/2].wheel_x = results["x"];
		wheel_entries[num_arts/2].wheel_y = results["y"];
		wheel_entries[num_arts/2].wheel_w = results["w"];
		wheel_entries[num_arts/2].wheel_a = results["a"];
		wheel_entries[num_arts/2].wheel_h = results["h"];
		wheel_entries[num_arts/2].wheel_r = results["r"];
	}
	local conveyor = Conveyor();
	conveyor.set_slots( wheel_entries );
	conveyor.transition_ms = 50;
	try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
