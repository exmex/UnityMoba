Shader "NTG/Battle/RoleDiffuseOutline" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,0)
}
SubShader {
	Tags { "Queue" = "Transparent"  }
	ZWrite On
	Cull Off

	Pass    
	{ 
		ZWrite Off

		CGPROGRAM  
		#pragma vertex vert  
		#pragma fragment frag  
		#include "UnityCG.cginc"   
		
		struct v2f {   
			float4 pos : SV_POSITION;    
		};   
		
		v2f vert(appdata_tan v)   
		{   
			v2f o;   
			float4 v2 = v.vertex;
			v2.xyz += v.normal*0.02;
			o.pos = mul (UNITY_MATRIX_MVP, v2);  

			return o;    
		}

		half4 frag (v2f i) : COLOR   
		{   
			return half4(0,0,0,1);				
		}    
		ENDCG   
	} 

	CGPROGRAM
	#pragma surface surf Lambert noforwardadd

	sampler2D _MainTex;
	half4 _Color;

	struct Input {
		float2 uv_MainTex;
	};

	void surf (Input IN, inout SurfaceOutput o) {

		if (_Color.a > 0) {
			o.Albedo = _Color.rgb;
			o.Alpha = _Color.a;
		} else {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			clip(c.a - 0.8);
		}	
	}
	ENDCG
}

Fallback "Mobile/VertexLit"
}
