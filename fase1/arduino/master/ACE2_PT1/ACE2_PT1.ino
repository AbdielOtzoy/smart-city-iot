// #################################
// DEFINIMOS LOS PINES DEL PROYECTO
// #################################

// Pines de semáforos  
const int semaforo1[3] = {6, 5, 4}; // rojo, amarillo, verde  
const int semaforo2[3] = {9, 8, 7}; // rojo, amarillo, verde  

// Estados de semáforos: {semáforo1, semáforo2}  
// Nota: 0 = rojo, 1 = amarillo, 2 = verde
int estados[][2] = {  
  {2, 0},  
  {1, 0},  
  {0, 2},  
  {0, 1}  
};  
const int numEstados = sizeof(estados) / sizeof(estados[0]);  

// Pines de los 7 HC-SR04  
const int Trig[7] = {22, 24, 26, 28, 30, 32, 34};  
const int Echo[7] = {23, 25, 27, 29, 31, 33, 35};  

// Distancias HC-SR04  
float distancias[7];  
long duration;

// Botones por zona  
const int BotonP[3] = {2, 3, 18}; //pines de buzzer 

// Buzzers por zonas  
const int Buzz[3] = {10, 11, 12}; // Zona1 -> Buzz[0], Zona2 -> Buzz[1], Zona3 -> Buzz[2]  

// Variables para buzzer
volatile bool buzzerTrigger[3] = {false, false, false};  
volatile int buzzerType[3] = {0, 0, 0}; // 0= ninguno , 1=boton, 2=movimiento, 3=piezo, 4=mq
volatile int buzzerStep[3] = {0, 0, 0};
volatile int buzzerPhase[3] = {0, 0, 0}; // 0=ON, 1=OFF
unsigned long buzzerPhaseStart[3] = {0, 0, 0};

// Sensores MQ  
const int mqPinA0 = A0;  
const int mqPinA1 = A1;  
const int mqPinA2 = A2;  
float mqReadings[3];  
const float mqThreshold = 320.0; // AQuí ESTÁ EL UMBRAL PARA LOS MQ --- RECORDEMOS TESTEARLO --- 

// Piezos eléctricos
const int piezoPin = 20;

// Flags para eventos que necesitan envío a Processing
volatile bool panicoTriggered[3] = {false, false, false}; // Para botones de pánico
volatile bool infraccionTriggered[7] = {false, false, false, false, false, false, false}; // Para infracciones por HC-SR04
volatile bool sismoTriggered = false; // Para sismo
unsigned long sismoTime = 0; // Timestamp del último sismo
// CREO QUE LAS DEMÁS ALERTAS NO SE MANDAN POR EL TIMESTAMP

// Para estados de semáforos
const String semEstados[3] = {"ROJO", "AMARILLO", "VERDE"};

// #################################
// DEFINIMOS LAS FUNCIONES PRINCIPALES
// #################################

// Función para obtener la duración de la fase actual basada en el tipo de alarma
// Esto se puede cambiar, hay que jugarlo para que suenen mejor
unsigned long getPhaseDuration(int type, int step, int phase) {
  switch (type) {
    case 1: // Alarma 1: Botones - 3 pitidos cortos (200ms ON, 200ms OFF)
      if (step >= 3) return 0;
      if (phase == 0) return 200; // ON
      return (step < 2 ? 200 : 0); // OFF solo entre pitidos, no después del último
    case 2: // Alarma 2: Movimiento en rojo - 2 pitidos largos (500ms ON, 300ms OFF)
      if (step >= 2) return 0;
      if (phase == 0) return 500; // ON
      return (step < 1 ? 300 : 0); // OFF solo entre pitidos
    case 3: // Alarma 3: Piezo - 5 pitidos rápidos (100ms ON, 100ms OFF)
      if (step >= 5) return 0;
      if (phase == 0) return 100; // ON
      return (step < 4 ? 100 : 0); // OFF solo entre pitidos
    case 4: // Alarma 4: MQ bajo - Pitido continuo largo (2000ms ON)
      if (step >= 1) return 0;
      if (phase == 0) return 2000; // ON
      return 0; // No OFF
    default:
      return 0;
  }
}

// Activar buzzer en una zona con un tipo de alarma específico
void ActivarBuzzZonaConTipo(int zona, int tipo) {  
  if (zona >= 0 && zona < 3 && tipo >= 1 && tipo <= 4) {  
    buzzerTrigger[zona] = true;  
    buzzerType[zona] = tipo;
    buzzerStep[zona] = 0;
    buzzerPhase[zona] = 0;
    buzzerPhaseStart[zona] = millis();
  }  
}

// Interrupciones por botón
void ActivarBuzzZona(int zona) {  
  ActivarBuzzZonaConTipo(zona, 1);
  panicoTriggered[zona] = true; // Flag para enviar PANICO
}

// Activar todos los buzzers
void ActivarTodosBuzz() {    
  for (int z = 0; z < 3; z++) {
    ActivarBuzzZonaConTipo(z, 3);
  }
  sismoTriggered = true; // Flag para enviar SISMO
  sismoTime = millis();
}

// ISR para alarmas
void ISR_BuzzerZona0() { ActivarBuzzZona(0); }  
void ISR_BuzzerZona1() { ActivarBuzzZona(1); }  
void ISR_BuzzerZona2() { ActivarBuzzZona(2); } 

// ISR para sismo
void ISR_Piezos() { ActivarTodosBuzz(); }

int estadoActualSem1 = 0;
int estadoActualSem2 = 0;

void setup() {  
  // Semáforos  
  for (int i = 0; i < 3; i++) {  
    pinMode(semaforo1[i], OUTPUT);  
    pinMode(semaforo2[i], OUTPUT);  
  }  

  // Configurar botones por zona
  for (int z = 0; z < 3; z++) {  
    pinMode(BotonP[z], INPUT_PULLUP);  
  }  

  // Configurar buzzers  
  for (int i = 0; i < 3; i++) {  
    pinMode(Buzz[i], OUTPUT);  
    digitalWrite(Buzz[i], LOW); // Asegurar apagado inicial
  }  

  // Adjuntar interrupciones para botones de zonas
  attachInterrupt(digitalPinToInterrupt(BotonP[0]), ISR_BuzzerZona0, FALLING);  
  attachInterrupt(digitalPinToInterrupt(BotonP[1]), ISR_BuzzerZona1, FALLING);
  attachInterrupt(digitalPinToInterrupt(BotonP[2]), ISR_BuzzerZona2, FALLING);

  attachInterrupt(digitalPinToInterrupt(piezoPin), ISR_Piezos, FALLING);

 // Inicializando los pines de los HC-SR04
  for (int i = 0; i < 7; i++) {
    pinMode(Trig[i], OUTPUT);
    pinMode(Echo[i], INPUT);
    digitalWrite(Trig[i], LOW);
  }

 // Inicializando el monitor serial
  Serial.begin(9600);  

  // Inicializar estados actuales
  estadoActualSem1 = estados[0][0];
  estadoActualSem2 = estados[0][1];
  // Imprimir estado inicial
  mostrarenSemaforos();
}

void mostrarEstado(int semaforo[], int estado) {
  for (int i = 0; i < 3; i++) {
    digitalWrite(semaforo[i], (i == estado) ? HIGH : LOW);
  }
}

// Función utilitaria para mostrar estado inicial en semáforos
void mostrarenSemaforos() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(semaforo1[i], (i == estadoActualSem1) ? HIGH : LOW);
  }
  for (int i = 0; i < 3; i++) {
    digitalWrite(semaforo2[i], (i == estadoActualSem2) ? HIGH : LOW);
  }
}

// Leer sensores MQ y almacenarlos en el arreglo
void leerMQSensors() {
  mqReadings[0] = analogRead(mqPinA0);
  mqReadings[1] = analogRead(mqPinA1);
  mqReadings[2] = analogRead(mqPinA2);
}

// Nueva función: verifica lecturas MQ y activa alarmas tipo 4 si están por debajo del umbral
void verificarMQYActivar() {
  for (int z = 0; z < 3; z++) {
    if (mqReadings[z] > mqThreshold) {
      ActivarBuzzZonaConTipo(z, 4);
      Serial.print("Alerta MQ bajo en zona "); Serial.print(z + 1); Serial.println(" (Tipo 4)");
    }
  }
}

// Lectura HC-SR04 para 7 zonas
void leerHC_SR04() {
  for (int z = 0; z < 7; z++) {
    // Inicializar trigger
    digitalWrite(Trig[z], LOW);
    delayMicroseconds(2);
    digitalWrite(Trig[z], HIGH);
    delayMicroseconds(10);
    digitalWrite(Trig[z], LOW);

    // Medir echo
    duration = pulseIn(Echo[z], HIGH, 30000);
    distancias[z] = duration * 0.0343 / 2.0;
  }
}

// Gestión de buzzers con patrones basados en tipo
void gestionarBuzzers() {
  for (int z = 0; z < 3; z++) {
    if (buzzerTrigger[z]) {
      unsigned long dur = getPhaseDuration(buzzerType[z], buzzerStep[z], buzzerPhase[z]);
      if (dur == 0) {
        digitalWrite(Buzz[z], LOW);
        buzzerTrigger[z] = false;
        buzzerType[z] = 0;
        continue;
      }

      unsigned long elapsed = millis() - buzzerPhaseStart[z];
      if (elapsed >= dur) {
        // Avanzar fase
        if (buzzerPhase[z] == 0) {
          // De ON a OFF
          digitalWrite(Buzz[z], LOW);
          buzzerPhase[z] = 1;
        } else {
          // De OFF a ON, avanzar step
          buzzerPhase[z] = 0;
          buzzerStep[z]++;
        }
        buzzerPhaseStart[z] = millis();

        // Verificar si la nueva fase tiene duración 0 (fin del patrón)
        dur = getPhaseDuration(buzzerType[z], buzzerStep[z], buzzerPhase[z]);
        if (dur == 0) {
          digitalWrite(Buzz[z], LOW);
          buzzerTrigger[z] = false;
          buzzerType[z] = 0;
          continue;
        }
      }

      // Establecer estado actual
      digitalWrite(Buzz[z], (buzzerPhase[z] == 0 ? HIGH : LOW));
    } else {
      digitalWrite(Buzz[z], LOW);
    }
  }
}

//Verifica distancias y activa buzzers según semáforo (con tipo 2), y setea flag para INFRACCION
void verificarYActivarBuzzerPorZonas() {
  // Zonas 0 1 y 2, HC04 1 2 y3 -> Semáforo1 en rojo (estado 0)
  for (int z = 0; z < 3; z++) {
    if (distancias[z] <= 3.0f) {
      if (estadoActualSem1 == 0) { // rojo
        // Mapeo: zona 0 -> Buzz[0] (Zona1), zona 1 -> Buzz[2] (Zona3), zona 2 -> Buzz[2] (Zona3)
        if (z == 0) {
          ActivarBuzzZonaConTipo(0, 2); // Zona1, tipo 2
          infraccionTriggered[z] = true; // Flag para enviar INFRACCION
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem1 rojo, Tipo 2)");
        } else if (z == 1) {
          // Zona2 -> Buzz[2]
          ActivarBuzzZonaConTipo(2, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem1 rojo, Tipo 2)");
        } else if (z == 2) {
          // Zona3 -> Buzz[2]
          ActivarBuzzZonaConTipo(2, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem1 rojo, Tipo 2)");
        }
      }
    }
  }

  // Zonas 3-6 (HC04 4-7) -> Semáforo2 en rojo 
  for (int z = 3; z < 7; z++) {
    if (distancias[z] <= 3.0f) {
      if (estadoActualSem2 == 0) { // rojo
        // Mapeo:
        // HC04 4 -> Zona4 -> Buzz[0]
        // HC04 5 -> Zona5 -> Buzz[1]
        // HC04 6 -> Zona6 -> Buzz[1]
        // HC04 7 -> Zona7 -> Buzz[2]
        int localIndex = z - 3; // 0..3
        if (localIndex == 0) {
          // Zona4
          ActivarBuzzZonaConTipo(0, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem2 rojo, Tipo 2)");
        } else if (localIndex == 1) {
          // Zona5
          ActivarBuzzZonaConTipo(1, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem2 rojo, Tipo 2)");
        } else if (localIndex == 2) {
          // Zona6
          ActivarBuzzZonaConTipo(1, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem2 rojo, Tipo 2)");
        } else if (localIndex == 3) {
          // Zona7
          ActivarBuzzZonaConTipo(2, 2);
          infraccionTriggered[z] = true;
          Serial.print("Alerta por HC"); Serial.print(z + 1); Serial.println(" (Sem2 rojo, Tipo 2)");
        }
      }
    }
  }
}

//Envía todos los datos a Processing en el formato esperado
void enviarDatosAProcessing() {
  unsigned long ts = millis();

  // Enviar SEMAFORO con mapeo: IDs 1,3,5,7 -> estado sem1; resto -> estado sem2
  Serial.println("SEMAFORO:1:" + semEstados[estadoActualSem1]);
  Serial.println("SEMAFORO:2:" + semEstados[estadoActualSem2]);
  Serial.println("SEMAFORO:3:" + semEstados[estadoActualSem1]);
  Serial.println("SEMAFORO:4:" + semEstados[estadoActualSem2]);
  Serial.println("SEMAFORO:5:" + semEstados[estadoActualSem1]);
  Serial.println("SEMAFORO:6:" + semEstados[estadoActualSem2]);
  Serial.println("SEMAFORO:7:" + semEstados[estadoActualSem1]);
  Serial.println("SEMAFORO:8:" + semEstados[estadoActualSem2]);
  Serial.println("SEMAFORO:9:" + semEstados[estadoActualSem2]);
  Serial.println("SEMAFORO:10:" + semEstados[estadoActualSem2]);

  // Enviar BUS usamos distancias[5] y [6] como ejemplo, HAY QUE MEJORAR ESTO PARA LEER POSICIÓN
  int busDist1 = (int)(distancias[3]); // TRANSMETRO
  int busDist2 = (int)(distancias[0]); // TRANSURBANO
  Serial.println("BUS:TRANSMETRO:1:" + String(busDist1));
  Serial.println("BUS:TRANSURBANO:2:" + String(busDist2));

  // Enviar INCENDIO 
  for (int i = 0; i < 2; i++) {
    int nivel = (int)mqReadings[i];
    String estado = (mqReadings[i] < mqThreshold) ? "ALERTA" : "NORMAL";
    Serial.println("INCENDIO:" + String(i + 1) + ":" + String(nivel) + ":" + estado);
  }

  // Enviar HUMO 
  int humoNivel = (int)mqReadings[2];
  String humoEstado = (mqReadings[2] < mqThreshold) ? "ALERTA" : "NORMAL";
  Serial.println("HUMO:" + String(humoNivel) + ":" + humoEstado);

  // Enviar SISMO 
  String nivelSismo = (millis() - sismoTime < 10000) ? "ALTO" : "BAJO";
  Serial.println("SISMO:" + nivelSismo + ":" + String(ts));

  // Enviar PANICO si --- VERIFICAR ESTO PORQUE EN EL PROCESSING HAY 6
  for (int z = 0; z < 3; z++) {
    if (panicoTriggered[z]) {
      Serial.println("PANICO:" + String(z + 1) + ":" + String(ts));
      panicoTriggered[z] = false; // Reset flag después de enviar
    }
  }

  // Enviar INFRACCION 
  for (int z = 0; z < 7; z++) {
    if (infraccionTriggered[z]) {
      Serial.println("INFRACCION:" + String(z + 1) + ":" + String(ts));
      infraccionTriggered[z] = false; // Reset flag
    }
  }

  // Enviar SISTEMA:OK para keep-alive
  Serial.println("SISTEMA:OK:" + String(ts));
}

// Función auxiliar para imprimir el estado actual de semáforos 
void imprimirEstados() {
  Serial.print("SEMA1="); Serial.print(estadoActualSem1);
  Serial.print("  SEMA2="); Serial.println(estadoActualSem2);
}

// Loop
void loop() {
  static int estadoSemaforoIndex = 0;          // índice para ciclo de semáforos
  static unsigned long cambioTiempo = 0;       // tiempo de cambio
  const unsigned long tiempoEstado = 5000;     // 5 segundos por estado
  
  // Leer sensores MQ
  leerMQSensors();
  Serial.print("MQ0: "); Serial.print(mqReadings[0]);
  Serial.print(" | MQ1: "); Serial.print(mqReadings[1]);
  Serial.print(" | MQ2: "); Serial.println(mqReadings[2]);

  // Verificar y activar alarmas para MQ (tipo 4)
  verificarMQYActivar();

  // Leer HC-SR04 para las 7 zonas
  leerHC_SR04();
  for (int z = 0; z < 7; z++) {
    Serial.print("D"); Serial.print(z+1); Serial.print(": "); 
    Serial.print(distancias[z]);
    Serial.print(" cm");
    if (z < 6) Serial.print(" | ");
  }
  Serial.println();

  // Gestión de buzzers (tiempos y patrones)
  gestionarBuzzers();

  // Actualizar estados actuales de semáforos
  estadoActualSem1 = estados[estadoSemaforoIndex][0];
  estadoActualSem2 = estados[estadoSemaforoIndex][1];

  // Control automático de semáforos
  if (millis() - cambioTiempo > tiempoEstado) {
    // Avanzar al siguiente estado
    estadoSemaforoIndex = (estadoSemaforoIndex + 1) % numEstados;
    // Actualizar estados actuales tras cambio
    estadoActualSem1 = estados[estadoSemaforoIndex][0];
    estadoActualSem2 = estados[estadoSemaforoIndex][1];
    // Mostrar el nuevo estado
    mostrarEstado(semaforo1, estadoActualSem1);
    mostrarEstado(semaforo2, estadoActualSem2);
    cambioTiempo = millis();
  }

  // Verificar y activar buzzer en función de distancias y estados de semáforo 
  verificarYActivarBuzzerPorZonas();

  // Enviar todos los datos a Processing (cada loop, ~1s por delay)
  enviarDatosAProcessing();

  // Imprimir estados 
  // imprimirEstados();

  delay(1000); // ajuste de tiempo según veamos la velocidad
}
