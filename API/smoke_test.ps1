# Prueba rápida de extremo a extremo de la API (requiere uvicorn corriendo).
$base = 'http://127.0.0.1:8000'
$email = "prueba$(Get-Date -Format yyyyMMddHHmmss)@test.com"

function Llamar {
    param($Metodo, $Ruta, $Cuerpo, $Cabeceras)

    $args = @{ Uri = "$base$Ruta"; Method = $Metodo; ContentType = 'application/json' }
    if ($Cuerpo) { $args.Body = ($Cuerpo | ConvertTo-Json -Depth 5) }
    if ($Cabeceras) { $args.Headers = $Cabeceras }

    try {
        return Invoke-RestMethod @args
    } catch {
        $codigo = [int]$_.Exception.Response.StatusCode
        return [pscustomobject]@{ status = $codigo; detalle = $_.ErrorDetails.Message }
    }
}

function Comprobar($nombre, $condicion) {
    if ($condicion) { Write-Host "OK   - $nombre" -ForegroundColor Green }
    else { Write-Host "FAIL - $nombre" -ForegroundColor Red; throw $nombre }
}

$salud = Llamar 'GET' '/health'
Comprobar 'GET /health' ($salud.status -eq 'ok')

$registro = Llamar 'POST' '/auth/register' @{
    nombre = 'Isaac Prueba'; email = $email; password = '123456'
}
Comprobar 'POST /auth/register' $registro.access_token
$token = $registro.access_token
$cabeceras = @{ Authorization = "Bearer $token" }

$login = Llamar 'POST' '/auth/login' @{ email = $email; password = '123456' }
Comprobar 'POST /auth/login' $login.access_token

$sinToken = Llamar 'GET' '/prestamos'
Comprobar 'GET /prestamos sin token devuelve 401' ($sinToken.status -eq 401)

$prestamo = Llamar 'POST' '/prestamos' @{
    cliente = 'Maria Lopez'
    dni = '12345678'
    monto = 1500.00
    interes = 150.00
    fecha_vencimiento = '2026-12-31'
    pagado = $false
} $cabeceras
Comprobar 'POST /prestamo' ($prestamo.id -gt 0)
Comprobar 'total_a_cobrar calculado' ([double]$prestamo.total_a_cobrar -eq 1650)
$id = $prestamo.id

$listado = Llamar 'GET' '/prestamos' -Cabeceras $cabeceras
Comprobar 'GET /prestamos' (@($listado).Count -eq 1)

$obtenido = Llamar 'GET' "/prestamos/$id" -Cabeceras $cabeceras
Comprobar "GET /prestamos/$id" ($obtenido.cliente -eq 'Maria Lopez')

$actualizado = Llamar 'PUT' "/prestamos/$id" @{ pagado = $true } $cabeceras
Comprobar 'PUT /prestamos/{id} marca pagado' ($actualizado.pagado -eq $true)

$eliminado = Llamar 'DELETE' "/prestamos/$id" -Cabeceras $cabeceras
Comprobar 'DELETE /prestamos/{id}' ($null -eq $eliminado.detalle)

$despues = Llamar 'GET' '/prestamos' -Cabeceras $cabeceras
Comprobar 'Lista vacía tras eliminar' (@($despues).Count -eq 0)

Write-Host 'Todas las pruebas pasaron.' -ForegroundColor Cyan
