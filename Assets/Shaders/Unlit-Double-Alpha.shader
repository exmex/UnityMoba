Shader "NTG/Unlit/Double-Alpha" {   
    Properties {   
        _MainTex ("MainTexture (RGB)", 2D) = "white" {}   
    }   
    SubShader    
    {        
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
		half4 frag (v2f i) : COLOR   
		{   
			half4 result = tex2D (_MainTex, i.uv); 
			clip(result.a - 0.8);
			return result; 
		}    
		ENDCG   
	}
		
    }   

    Fallback "Mobile/VertexLit"
}  