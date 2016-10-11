#version 120    
uniform sampler2D tex0;
uniform vec4 bkg_color;
uniform float time;
void main (void)
{
  vec2 p = -1.0 + 2.0 * gl_TexCoord[0].xy;
  float r = sqrt(dot(p,p));
  if (r < 1.0)
  {
    vec2 uv;
    float f = (1.0-sqrt(1.0-r))/(r);
    uv.x = p.x*f + 0.0;
    uv.y = p.y*f + 0.0;
    gl_FragColor = vec4(texture2D(tex0,((uv.xy + 1.)/2.)).rgb,1.0);
  }
  else
  {
    gl_FragColor = bkg_color;
  }
}

// vec2 tc = gl_TexCoord[0].xy;
//  vec2 p = -1.0 + 2.0 * tc;
//  float r = dot(p,p);
//  if (r > 1.0) discard; 
//  float f = (1.0-sqrt(1.0-r))/(r);
//  vec2 uv;
//  uv.x = p.x*f + time;
//  uv.y = p.y*f + time;
//  gl_FragColor = vec4(texture2D(tex0,uv).xyz, 1.0);