// Simplified Additive Particle shader. Differences from regular Additive Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "NTG/Battle/RangeHint" {
Properties {
	_MainTex ("Base Texture", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,1)  
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off 
	Lighting Off 
	ZWrite Off 
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
		//ZTest Always
			CGPROGRAM   
				#pragma vertex vert  
				#pragma fragment frag
				
				#include "UnityCG.cginc"   
				
				struct v2f {   
					float4 pos : SV_POSITION;   
					float2 uv : TEXCOORD0;   
				};   
				
				v2f vert(appdata_tan v)   
				{   
					v2f o;   
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);  
					o.uv = v.texcoord; 
					return o;    
				}   
				
				sampler2D _MainTex;  
				float4 _Color; 

				half4 frag (v2f i) : COLOR   
				{   
					half4 result = tex2D (_MainTex, i.uv); 
					result*=_Color;
					return result; 
				}    
			ENDCG 
		}
		Pass {
		ZTest Greater
			CGPROGRAM   
				#pragma vertex vert  
				#pragma fragment frag
				
				#include "UnityCG.cginc"   
				
				struct v2f {   
					float4 pos : SV_POSITION;   
					float2 uv : TEXCOORD0;   
				};   
				
				v2f vert(appdata_tan v)   
				{   
					v2f o;   
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);  
					o.uv = v.texcoord; 
					return o;    
				}   
				
				sampler2D _MainTex;  
				float4 _Color; 

				half4 frag (v2f i) : COLOR   
				{   
					half4 result = tex2D (_MainTex, i.uv); 
					result*=_Color;
					result.a /= 3;
					return result; 
				}    
			ENDCG 
		}
	}
}
}