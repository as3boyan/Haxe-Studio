package plugin.misterpah;
import jQuery.*;
import js.Browser;

@:keep @:expose class ProjectAccess
{
	static private var plugin:Map<String,String>;

    static public function main():Void
    {
	register_listener();
	register_shortcutkey();
    }
	
	static private function register_shortcutkey():Void
	{
	untyped $.keyStroke( 79, { modKeys: ['ctrlKey','shiftKey'] }, function(){  Main.message.broadcast("core:FileMenu.openProject","plugin.misterpah.ProjectAccess",null); }); // CTRL + SHIFT + O
	}	
	
	static public function register_listener():Void
	{
	Main.message.listen("core:FileMenu.openProject","plugin.misterpah.ProjectAccess",open_project);
	Main.message.listen("core:FileMenu.closeProject","plugin.misterpah.ProjectAccess",close_project);
	Main.message.listen("plugin.misterpah.ProjectAccess","plugin.misterpah.ProjectAccess",parse_project_complete);
	
	}
	
    static public function open_project():Void
    {
        var filedialog = new ui.FileDialog();
		filedialog.show(openProjectHandler);
    }

    static private function openProjectHandler(path:String,newFile:Bool=false):Void
    {
        Main.session.project_xml = path;
        parse_project();
    }	
	
	static private function parse_project_complete():Void
	{
		Main.message.broadcast("plugin.misterpah.ProjectAccess:open_project.complete","plugin.misterpah.ProjectAccess",null);
	}
	
	
    private static function close_project()
    {
        Main.session.project_xml = '';
        Main.session.project_folder = '';
        Main.session.project_xml_parameter = '';
		Main.message.broadcast("plugin.misterpah.ProjectAccess:close_project.complete","plugin.misterpah.ProjectAccess",null);
    }
    
    
    
	public static function parse_project()
    {
		var exec_str = "";
		var filename = Main.session.project_xml;
		var temp = filename.split(".");
		var filename_ext = temp.pop();

	    var projectFolder = filename.split(Utils.path.sep);
	    projectFolder.pop();
	    Main.session.project_folder = projectFolder.join(Utils.path.sep);		
	    
	    
	    var compiler = "";
	    if (filename_ext == "xml")
	    	{
	    	compiler = "lime display -hxml flash";
	    	}
	    else if (filename_ext == "hxml")
	    	{
	    	compiler = "%CAT% \""+filename+"\"";
	    	}
		Utils.exec(["cd %CD% \""+Main.session.project_folder+"\"",compiler],function(error,stdout,stderr)
			{
				var the_error = false;
				if (stderr != "") {the_error = true;}
				if (the_error == true)
				{
					trace(error);trace(stdout);trace(stderr);
					var notify = new ui.Notify();
					notify.type = "error";
					notify.content = "not a valid Haxe Project File ( XML / HXML )";
					notify.show();	
					Main.session.project_xml = "";					
				}
				else
				{
					//new JQuery('#projectContent').html(stdout);
					var content_push:Array<String> = new Array();
					var content:Array<String> = stdout.split("\n");

					var i = 0;
					for (i in 0...content.length)
					{
						var cur = content[i];				
						for (arg in ['-lib', '-cp', '-main', '-D']) 
						{
							if (cur.indexOf(arg) == 0) // starts with
							{
								content_push.push(cur);
								break;
							}
						}                       

					}

			        Main.session.project_xml_parameter = content_push.join(' ');					

			        trace(Main.session.project_xml_parameter);
					if (Main.session.project_xml_parameter != "")
						{
						Main.message.broadcast("plugin.misterpah.ProjectAccess:system_parse_project.complete","plugin.misterpah.ProjectAccess",[]);
						}
				} // stdout != ""
			
			});	    	
	    
	    /*
		if (filename_ext == "xml")
		{
			switch (Utils.getOS()) 
			{
				case Utils.WINDOWS:
					exec_str = "cd /D " + '"'+ Main.session.project_folder +'"'+" & lime display -hxml flash";
				case Utils.LINUX:
					exec_str = "cd " +'"'+ Main.session.project_folder +'"'+ " ; lime display -hxml flash";
				default:
					
			}
		}
		else if (filename_ext == "hxml")
		{
			switch (Utils.getOS()) 
			{
				case Utils.WINDOWS:
					exec_str = "cd /D "+'"'+ Main.session.project_folder +'"'+" & type "+'"'+ filename+'"';
				case Utils.LINUX:
					exec_str = "cd " +'"'+ Main.session.project_folder +'"'+ " ; cat "+'"'+filename+'"';
				default:
					
			}							
		}
		trace(exec_str);
		*/
		/*
		Utils.exec(exec_str,
			{},
			function(error, stdout:String,stderr:String){
				
				var the_error = false;
				if (stderr != "") {the_error = true;}
				if (the_error == true)
				{
					trace(error);trace(stdout);trace(stderr);
					var notify = new ui.Notify();
					notify.type = "error";
					notify.content = "not a valid Haxe Project File ( XML / HXML )";
					notify.show();	
					Main.session.project_xml = "";					
				}
				else
				{
					//new JQuery('#projectContent').html(stdout);
					var content_push:Array<String> = new Array();
					var content:Array<String> = stdout.split("\n");
					var i = 0;
					for (i in 0...content.length)
					{
						var cur = content[i];
						
						for (arg in ['-lib', '-cp', '-main', '-D']) 
						{
							if (cur.indexOf(arg) == 0) // starts with
							{
								content_push.push(cur);
								break;
							}
						}                       
					}
			        Main.session.project_xml_parameter = content_push.join(' ');					
			        //trace(Main.session.project_xml_parameter);
					if (Main.session.project_xml_parameter != "")
					{
						Main.message.broadcast("core:utils.system_parse_project.complete","core:utils");
					}
				} // stdout != ""
			});
		*/
	
	}           
    
}
