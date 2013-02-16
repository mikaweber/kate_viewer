package ;
import js.Lib;
//import js.webgl.TypedArray;
//import js.webgl.WebGLContext;
//import js.webgl.DOMTypes;
/**
 * ...
 * @author FILA
 */

class Exp1 {
	
	public static var WIDTH:Int = 1024;
	public static var HEIGHT:Int = 1024;
	
	private var _context3D:Dynamic;
	
	public function new() {
		
		// step0
		
		var document:Dynamic = Lib.document;
		var body:Dynamic = document.body;
		body.style.marginTop = 0;
		body.style.marginLeft = 0;
		
		var htmlDom:Dynamic = document.createElement( "canvas" );
		body.appendChild( htmlDom );
		
		var canvas:Dynamic = cast htmlDom;
		canvas.width = WIDTH;
		canvas.height = HEIGHT;
		
		this._context3D = canvas.getContext( "webgl" );
		if ( this._context3D == null ) {
			this._context3D = canvas.getContext( "experimental-webgl" );
		}
		
		if ( this._context3D == null ) {
			Lib.alert( " ... " );
		}
		
		// step1
		
		this._context3D.viewport( 0, 0, WIDTH, HEIGHT );
		this._context3D.clearColor( 0.0, 0.0, 0.0, 1.0 );
		
		//this._context3D.enable(this._context3D.DEPTH_TEST);
		//this._context3D.depthFunc(this._context3D.LEQUAL);

		
		this._context3D.clear( this._context3D.COLOR_BUFFER_BIT);// | this._context3D.DEPTH_BUFFER_BIT );
		
		
		// perspective projection matrix
		
		var scaleX:Float = 2.0 / WIDTH;
		var scaleY:Float = -2.0 / HEIGHT;
		var perspectiveProjectionMatrix:Float32Array = new Float32Array( [
		  scaleX, 0.0, 0.0, 0.0, 0.0, scaleY, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, -1.0, 1.0, 0.0, 1.0
		] );
		
		
		var modelViewMatrix:Float32Array = new Float32Array( [
		  1.0, 0.0, 0.0, 0.0,
		  0.0, 1.0, 0.0, 0.0,
		  0.0, 0.0, 1.0, 0.0,
		  100.0, 100.0, 0.0, 1.0
		] );
		
		
		// step2
		
		var vertexProgramCode:String = 
			"attribute vec2 aVertexPosition;											\n"+
			"uniform mat4 ppMatrix;														\n"+
			"uniform mat4 mvMatrix;														\n"+
			"void main() {																\n"+
			"	gl_Position = ppMatrix * mvMatrix * vec4(aVertexPosition,0.0,1.0);		\n"+
			"}																			\n";
		
		var fragmentProgramCode:String =
			"#if GL_ES																	\n"+
			"precision highp float;														\n"+
			"#endif																		\n"+
			"uniform vec4 uColor;														\n"+
			"void main() {																\n"+
			"	gl_FragColor = uColor;													\n"+
			"}																			\n";
		
		var vertexProgram:Dynamic = this._context3D.createShader( this._context3D.VERTEX_SHADER );
		this._context3D.shaderSource( vertexProgram, vertexProgramCode );
		this._context3D.compileShader( vertexProgram );
                                
		var fragmentProgram = this._context3D.createShader( this._context3D.FRAGMENT_SHADER );
		this._context3D.shaderSource( fragmentProgram, fragmentProgramCode );
		this._context3D.compileShader( fragmentProgram );
                                
		var program3D:Dynamic = this._context3D.createProgram();
		this._context3D.attachShader( program3D, vertexProgram );
		this._context3D.attachShader( program3D, fragmentProgram );
		this._context3D.linkProgram( program3D );
		
		// debug:
		if ( !this._context3D.getShaderParameter( vertexProgram, this._context3D.COMPILE_STATUS ) )
			Lib.alert( this._context3D.getShaderInfoLog( vertexProgram ) );
 
		if ( !this._context3D.getShaderParameter( fragmentProgram, this._context3D.COMPILE_STATUS ) )
			Lib.alert( this._context3D.getShaderInfoLog( fragmentProgram ) );
                                
		if ( !this._context3D.getProgramParameter( program3D, this._context3D.LINK_STATUS ) )
			Lib.alert( this._context3D.getProgramInfoLog( program3D ) );
			
		//step3
		
		//vertex buffer
		var vertices:Float32Array = new Float32Array( [
			0.0, 0.0,
			0.0, 100.0,
			100.0, 0.0,
			100.0, 100.0
		] );
		var vertexBuffer:Dynamic = this._context3D.createBuffer();
		this._context3D.bindBuffer( this._context3D.ARRAY_BUFFER, vertexBuffer );
		this._context3D.bufferData( this._context3D.ARRAY_BUFFER, vertices, this._context3D.STATIC_DRAW );
		var dataPerVertex:Int = 2;
		var verticesNum:Int = 4;
		
		//index buffer
		var indices:Uint16Array = new Uint16Array( [
			0, 1, 2, 1, 2, 3
		] );
		var indicesBuffer:Dynamic = this._context3D.createBuffer();
		this._context3D.bindBuffer( this._context3D.ELEMENT_ARRAY_BUFFER, indicesBuffer );
		this._context3D.bufferData( this._context3D.ELEMENT_ARRAY_BUFFER, indices, this._context3D.STATIC_DRAW );
		
		
		//step4 BRUTALITY DRAW
		
		this._context3D.useProgram( program3D );
		
		//vertex uniform
		program3D.ppMatrix = this._context3D.getUniformLocation ( program3D, "ppMatrix" );
		this._context3D.uniformMatrix4fv( program3D.ppMatrix, false, perspectiveProjectionMatrix );
		
		program3D.mvMatrix = this._context3D.getUniformLocation ( program3D, "mvMatrix" );
		this._context3D.uniformMatrix4fv( program3D.mvMatrix, false, modelViewMatrix );
		
		//fragment uniform
		program3D.uColor = this._context3D.getUniformLocation( program3D, "uColor" );
		this._context3D.uniform4fv( program3D.uColor, [ 1.0, 0.0, 0.0, 1.0 ] );
        
		//vertex attribute
		program3D.aVertexPosition = this._context3D.getAttribLocation( program3D, "aVertexPosition" );
		
		this._context3D.vertexAttribPointer( program3D.aVertexPosition, dataPerVertex, this._context3D.FLOAT, false, 0, 0);
		this._context3D.enableVertexAttribArray( program3D.aVertexPosition );
		
		
		this._context3D.drawElements( this._context3D.TRIANGLES, 6, this._context3D.UNSIGNED_SHORT, 0 );
		
		
		//varying vec4 color;
		//color       = aVertexColor;
		//f
		//varying vec4 color;
	
		
		
		
		
		//mvMatrix
	}
	
	public function step():Void {
		
	}
	
}