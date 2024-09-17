vec3 palette( float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.263, 0.416, 0.557);
  return a + b*cos( 6.28318 * (c*t +d) );
}

float oscillate(float time, float minValue, float maxValue, float frequency) {
    // Calculate the range of our oscillation
    float range = maxValue - minValue;
    
    // Use sine function, phase-shifted to start at the lowest point
    float normalized = 0.5 + 0.5 * sin(time * frequency - 3.14159 * 0.5);
    
    // Scale to our desired range and shift to our minimum value
    return minValue + normalized * range;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  // range from 0..1
  // center becomes 0.0 and values range from -1..1 on x and y
  //vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
  //adjust for aspect ratio
  //uv.x *= iResolution.x / iResolution.y;
  
  // which is the same as 
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  
  // original coordinates before we fract them below
  vec2 uv0 = uv;
  
  vec3 finalColor = vec3(0.0);
  
  float offset = 1000.;
  
  for (float i = 0.0; i < 4.0; i++) {
  

      // once again center each fraction at it's own local 0.0
      //uv = fract(uv * iTime * 0.01 ) - 0.5;
      
      // control frequency of complexity change
      float compfreq = oscillate(iTime, .05, 0.5, .01);

      // from simple to complex over time driven by compfreq
      float complexity = oscillate(iTime, 0.00001, 2., compfreq);
   
      uv = fract(uv * complexity ) - 0.5;
      
      // local distance within each fract
      // float d = length(uv);
      // this time add the exponential function of the length of the global distance
      float d = length(uv) + exp(-length(uv0));
      

      // uv0 gets the original coordinates rather than the fractional ones
      // using its length here allows different color schemes in each fract  
      vec3 col = palette(length(uv0) + i *.1 + iTime*.1);

      // sdf - signed distance function - takes a position as space as input and
      // returns distance from that position to a given shape
      // signed because outside it's positive and inside it's negative
      d = sin(d * 8. + iTime) / 8.;
      d = abs(d);

      // d = smoothstep(0.0,0.1, d);

      // inverse makes it glow some - oscillate how much it glows
      float glowify = oscillate(iTime, 0.5, 3.5, 1.);
      // d = 0.01/d;
      d = pow(0.01 / d, glowify);
  
      finalColor += col * d;
  }

  fragColor = vec4(finalColor, 1.);
}
