Shader "NTG/Battle/RoleDiffuse" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,0)
}
SubShader {
	Cull Off

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
