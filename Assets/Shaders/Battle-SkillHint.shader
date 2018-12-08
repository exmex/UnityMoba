// Simplified Additive Particle shader. Differences from regular Additive Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "NTG/Battle/SkillHint" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
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

				half4 frag (v2f i) : COLOR   
				{   
					half4 result = tex2D (_MainTex, i.uv); 
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

				half4 frag (v2f i) : COLOR   
				{   
					half4 result = tex2D (_MainTex, i.uv); 
					//result /= 2;
					result.a /= 3;
					return result; 
				}    
			ENDCG 
		}
	}
}
}