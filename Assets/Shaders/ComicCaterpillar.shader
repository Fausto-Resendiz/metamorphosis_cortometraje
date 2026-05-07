Shader "Custom/ComicCaterpillar" // Nombre del shader dentro de Unity
{
    Properties
    {
        // Textura principal que se aplicará al objeto
        _MainTex("Texture", 2D) = "white" {}

        // Color que se usará para las zonas en sombra (estilo cómic)
        _ShadowColor("Shadow Color", Color) = (0.1,0.1,0.1,1)

        // Color que se usará para las zonas iluminadas
        _LightColor("Light Color", Color) = (1,1,1,1)

        // Umbral que define dónde empieza la sombra (corte duro tipo toon)
        _Threshold("Shadow Threshold", Range(0,1)) = 0.5
    }

    SubShader
    {
        // Indica que este shader renderiza objetos opacos
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

            // Definimos qué funciones serán el vertex y fragment shader
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            // Librería de Unity con funciones útiles (IMPORTANTE)
            #include "UnityCG.cginc"

            // Variables que vienen de Properties
            sampler2D _MainTex;   // Textura
            float4 _ShadowColor;  // Color sombra
            float4 _LightColor;   // Color luz
            float _Threshold;     // Umbral de sombra

            // Estructura de entrada del vertex shader
            struct vertexInput
            {
                float4 vertex : POSITION; // Posición del vértice
                float2 uv : TEXCOORD0;    // Coordenadas UV (textura)
                float3 normal : NORMAL;   // Normal del vértice
            };

            // Estructura de salida del vertex shader
            struct vertexOutput
            {
                float4 pos : SV_POSITION; // Posición final en pantalla
                float2 uv : TEXCOORD0;    // UV que se pasan al fragment shader
                float3 normalDir : TEXCOORD1; // Normal transformada
            };

            // ===== VERTEX SHADER =====
            vertexOutput vertexShader(vertexInput v)
            {
                vertexOutput o;

                // Convierte la posición del objeto a coordenadas de pantalla
                o.pos = UnityObjectToClipPos(v.vertex);

                // Pasa las coordenadas UV sin modificar
                o.uv = v.uv;

                // Convierte la normal del objeto a espacio mundo
                // (esto es necesario para calcular la iluminación correctamente)
                o.normalDir = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            // ===== FRAGMENT SHADER =====
            fixed4 fragmentShader(vertexOutput i) : SV_TARGET
            {
                // Dirección de la luz principal (normalizada)
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Producto punto entre la normal y la luz
                // Esto nos dice cuánto le pega la luz al fragmento
                float NdotL = dot(i.normalDir, lightDir);

                // ===== SOMBRA TIPO CÓMIC =====
                // step genera un corte duro:
                // si NdotL < Threshold → 0 (sombra)
                // si NdotL >= Threshold → 1 (luz)
                float shade = step(_Threshold, NdotL);

                // Obtiene el color de la textura
                float4 tex = tex2D(_MainTex, i.uv);

                // Mezcla entre sombra y luz según "shade"
                // lerp(a, b, t):
                // t=0 → a (sombra)
                // t=1 → b (luz)
                float4 finalColor = lerp(_ShadowColor * tex, _LightColor * tex, shade);

                // Color final del píxel
                return finalColor;
            }

            ENDCG
        }
    }

    // Shader de respaldo si algo falla
    Fallback "Diffuse"
}