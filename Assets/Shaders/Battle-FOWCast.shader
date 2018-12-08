// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "NTG/Battle/FOWCast"
{
	Properties 
	{
		_FogOfWarTex ("FogOfWar Tex", 2D) = "black" {}
	}
    SubShader 
    {
        Tags {"Queue"="Transparent"}
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

        Pass 
        {        	
            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		   
			#include "UnityCG.cginc"

			uniform sampler2D _FogOfWarTex;
			uniform sampler2D _NoiseTex;
			uniform float4x4 _MatCastViewProj;
		
			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base input)
			{
				v2f output;
				output.pos = mul (UNITY_MATRIX_MVP, input.vertex);

				half4 UVFogOfWar = mul (mul (_MatCastViewProj, unity_ObjectToWorld), input.vertex);

				output.uv = UVFogOfWar.xy + 0.5;

				return output;
			}

			float4 frag(v2f input) : COLOR 
			{				  
				//input.uv.y = 1 - input.uv.y;

				half fAlpha = tex2D (_FogOfWarTex, input.uv).a;
				fixed noise = tex2D(_NoiseTex, input.uv).r;
                          
                return half4(0,0,0,fAlpha*noise*1.1);
			}

            ENDCG
        }
    }
}
