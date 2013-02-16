package ;
import haxe.Timer;

class Main {
	
	static private var exp:Exp1;
	
	static function main() {
		Main.exp = new Exp1();
		
		var timer = new Timer( 16 ); 
		timer.run = Main.onEnterFrame;
	}
	
	static public function onEnterFrame():Void {
		Main.exp.step();
	}
	
}