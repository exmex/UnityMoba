Shader "NTG/Battle/Role" {   
    Properties {   
        _MainTex ("MainTexture (RGB)", 2D) = "white" {} 
		_Color ("Main Color", Color) = (1,1,1,0)
		_Hidden ("Hidden", Int) = 0
    }   
    SubShader    
    {   
	//Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
	//Blend SrcAlpha OneMinusSrcAlpha
	Cull Off

        Pass
        {    	
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
		half4 _Color;
		int _Hidden;

		half4 frag (v2f i) : COLOR   
		{   
			half4 result;
			if (_Color.a > 0) {
				result = _Color;
			} else {
				result = tex2D (_MainTex, i.uv); 
				clip(result.a - 0.8);
			}
			//if (_Hidden > 0) {
			//	result.a *= 0.3;
			//}
			return result; 
		}    
		ENDCG   
	}
		
    }   

    Fallback "Mobile/VertexLit"
}  