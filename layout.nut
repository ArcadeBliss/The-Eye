////////////////////////////////////////////////////////////////////////////////////////////////////////
// The Eye: Designed by verion / coded by ArcadeBliss
// credits to omegaman for the wheel conveyour values
////////////////////////////////////////////////////////////////////////////////////////////////////////

// ToDo:
// LOTS!
// - move all variables to the SETTINGS Table to allow for 16x9 or 800x600 layout
// - allow user to choose 4:3 or 16:9 in layout options
// - animate the eye



	class UserConfig {
	   </ label="Select BG art", help="Blur enables art for all consoles; otherwise choose blue, retro, black or flyer for bg", options="blur,blue,retro,black,flyer", order=1 /> enable_bg="blur";
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

	/////////////////////////////////////
	//
	//  Debugging
	//
	/////////////////////////////////////
		local counter = 0;
		/*fe.layout.height = 1920
		fe.layout.height = 721*/
		function debug(source)
		{
			print(counter+": FROM: "+ source + "\n");
			counter++;
		}




	local display_options = fe.get_config();
	// modules
	fe.load_module("fade");
	fe.load_module( "animate" );
	fe.load_module( "conveyor" );

// --------------------------------
//	Layout Variables
// --------------------------------
	//
	// Object positioning helpers
	//
	local viewport_width = null; 		// resized width of the orignal PSD Layout design
	local viewport_height = null;		// resized height of the original PSD Layout design
	local offset_x = null;								// the offset to use when positioning objects on the x axis
	local offset_y = null;								// the offset to use when positioning objects on the y axis
	const PSD_WIDTH = 1920;
	const PSD_HEIGHT = 1356;


	// Varialbles to be added to the SETTINGS Table
	local num_arts = 8; // the number of wheel entries
	//the wheel setup for 640x480 / change for 16x9 layouts
	/*local wheel_x = [ flx*0.80, flx*0.795, flx*0.756, flx*0.725, flx*0.70, flx*0.68, flx*0.64, flx*0.68, flx*0.70, flx*0.725, flx*0.756, flx*0.76, ];
	local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.436, fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99, ];
	local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.24, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
	local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
	local wheel_h = [  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, flh*0.17,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, ];
	local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];*/

// ----------------------------------------
//
//             set up classes
//
// ----------------------------------------

	//
	//	slot class to hold the wheel entries
	//
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
			base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
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


// ----------------------------------------
//             Add Layout Objects
// ----------------------------------------

	// The orginal layout is 1920x1356. These variables are used to
	// resize the original layout and calculate the offset to use for the
	// positioning of objects based upon the screen`s aspect ratio
	if ((fe.layout.height * 16.0 / fe.layout.width) == 9.0)
	{
		// test for 16x9 screen apect
		debug("16x9");
		viewport_width = fe.layout.width;
		viewport_height = PSD_HEIGHT * fe.layout.width / PSD_WIDTH ;
		offset_x = 0;
		offset_y = viewport_height * 0.203539823 / 2 * -1;
	} else {
		debug("4x3");
		// default to 4x3 aspect ratio
		viewport_width = PSD_WIDTH * fe.layout.height / PSD_HEIGHT;
		viewport_height = fe.layout.height;
		offset_x = 0;
		offset_y = 0;
	}

	//
	//	Load fan art
	//
	local fan_art = fe.add_artwork(
		"fanart",
		0 + offset_x,
		0 + offset_y,
		viewport_width,
		viewport_height
	);
	fan_art.preserve_aspect_ratio = true;

	//
	//	Load snap
	//
	local video = fe.add_artwork("snap",36,199,1000,500);
	local sh = fe.add_shader( Shader.VertexAndFragment, "assets/shaders/sphere.vert", "assets/shaders/sphere.frag" );
	sh.set_param( "bkg_color", 0, 0, 0 ,0 );
	sh.set_param( "time", 0.5 );
	sh.set_texture_param("tex0");
	video.shader = sh;
	//
	//	Load eye backdrop
	//
	local backdrop = fe.add_image(
		"assets/uielements/backdrop.png",
		0 + offset_x,
		0 + offset_y,
		viewport_width,
		viewport_height
	);




	// //
	// //	Configure Conveyor and Slots
	// //
	// local wheel_entries = [];
	// for ( local i=0; i<num_arts/2; i++ )
	// {
		// wheel_entries.push( WheelEntry() )
		// wheel_entries[i].wheel_x = settings[wheel_x]
		// wheel_entries[i].wheel_y = settings[wheel_y]
		// wheel_entries[i].wheel_w = settings[wheel_w]
		// wheel_entries[i].wheel_a = settings[wheel_a]
		// wheel_entries[i].wheel_h = settings[wheel_h]
		// wheel_entries[i].wheel_r = settings[wheel_r]
	// }
	// local remaining = num_arts - wheel_entries.len();

	// // we do it this way so that the last wheelentry created is the middle one showing the current
	// // selection (putting it at the top of the draw order)
	// for ( local i=0; i<remaining; i++ )
	// {
		// wheel_entries.insert( num_arts/2, WheelEntry() );
		// wheel_entries[num_arts/2].wheel_x = settings[wheel_x]
		// wheel_entries[num_arts/2].wheel_y = settings[wheel_y]
		// wheel_entries[num_arts/2].wheel_w = settings[wheel_w]
		// wheel_entries[num_arts/2].wheel_a = settings[wheel_a]
		// wheel_entries[num_arts/2].wheel_h = settings[wheel_h]
		// wheel_entries[num_arts/2].wheel_r = settings[wheel_r]
	// }
	// local conveyor = Conveyor();
	// conveyor.set_slots( wheel_entries );
	// conveyor.transition_ms = 50;
	// try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }

	// //
	// //	Test Eye Shader
	// //
	//fe.add_artwork("snap",0,0,500,500);
	/*local test = fe.add_artwork("snap",650,0,500,500);
	local test2 = fe.add_artwork("snap",650,500,500,500);

	// Circle  Shader
    local sh = fe.add_shader( Shader.VertexAndFragment, "assets/shaders/circle.vert", "assets/shaders/circle.frag" );
	sh.set_param( "border_size", 0.01 )
	sh.set_param( "disc_radius", 0.5 )
	sh.set_param( "disc_color", 0, 0, 0 ,0 )
	sh.set_param( "disc_center", 0.5, 0.5 )
	sh.set_texture_param("tex0");
	test.shader = sh;*/

	/*// Sphere  Shader
    local sh = fe.add_shader( Shader.VertexAndFragment, "assets/shaders/sphere.vert", "assets/shaders/sphere.frag" );
	sh.set_param( "bkg_color", 0, 0, 0 ,0 );
    sh.set_param( "time", 0.5 );
	sh.set_texture_param("tex0");
	test2.shader = sh;*/
	// {
  // vec2 p = -1.0 + 2.0 * gl_TexCoord[0].xy;
  // float r = sqrt(dot(p,p));
  // if (r < 1.0)
  // {
    // vec2 uv;
    // float f = (1.0-sqrt(1.0-r))/(r);
    // uv.x = p.x*f + 0.1;
    // uv.y = p.y*f + 0.1;
    // gl_FragColor = vec4(texture2D(tex0,((uv.xy + 1.)/2.)).rgb,1.0);
  // }
  // else
  // {
    // gl_FragColor = bkg_color;
  // }
// }
