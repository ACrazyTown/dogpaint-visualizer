import flixel.graphics.tile.FlxGraphicsShader;

// shoutout goat https://www.shadertoy.com/view/MsSSDz
class CircleWarpShader extends FlxGraphicsShader
{
    @:glFragmentSource("
    #pragma header

    #define dPI 6.28318530718	// 2*PI
    // #define sR 0.8			// small radius
    // #define bR 1.0 				// big radius

    uniform float sR;
    uniform float bR;

    // void mainImage( out vec4 fragColor, in vec2 fragCoord )
    void main()
    {
        // calc coordinates on the canvas
        // vec2 uv = fragCoord.xy / iResolution.xy*2.-vec2(1.);
        vec2 uv = openfl_TextureCoordv * 2. - vec2(1.);
        // uv.x *= iResolution.x/iResolution.y;
        uv.x *= openfl_TextureSize.x / openfl_TextureSize.y;
        
        // calc if it's in the ring area
        float k = 0.0;
        float d = length(uv);
        if(d>sR && d<bR)
            k = 1.0;
        
        // calc the texture UV
        // y coord is easy, but x is tricky, and certain calcs produce artifacts
        vec2 tUV = vec2(0.0,0.0);
        
        // 1st version (with artifact)
        //tUV.x = atan(uv.y,uv.x)/dPI;
        
        // 2nd version (more readable version of the 3rd version)
        //float disp = 0.0;
        //if(uv.x<0.0) disp = 0.5;
        //tUV.x = atan(uv.y/uv.x)/dPI+disp;
        
        // 3rd version (no branching, ugly)
        // tUV.x = atan(uv.y/uv.x)/dPI+0.5*(1.-clamp(uv.x,0.0,1.0)/uv.x);
        tUV.x = atan(uv.y, uv.x) / dPI;
        tUV.x = fract(tUV.x);
        tUV.x = clamp(tUV.x, 0.0, 0.99);

        tUV.y = (d-sR)/(bR-sR);
        
        // output pixel
        // vec3 col = texture(iChannel0, tUV).rgb;
        vec4 texSample = flixel_texture2D(bitmap, tUV);
        vec3 col = texSample.rgb;
        gl_FragColor = vec4(col*k,texSample.a);
    }
    ")

    public function new()
    {
        super();

		this.sR.value = [0.75];
		this.bR.value = [0.95];
    }
}
