/*
Criado por Marcelo Maurin Martins
Data: 30/01/2014
*/

#include <stdlib.h>
#include<stdio.h>
#include<string.h>    //strlen

#ifdef _WIN32
#include <winsock2.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <sapi.h>
#include <malloc.h>
#pragma comment(lib, "ws2_32.lib") // Esta linha é necessária para linkar a biblioteca ws2_32.lib com o programa
#endif

//Constantes
#define PORTSRV 8096


//DeclaraÃ§Ã£o de variaveis publicas
char sTipoVoz[50];  //ResponsÃ¡vel pelo marcacao do tipodevoz


// Prototipos das funcoes do eSpeak que serao usados
typedef int (*espeakInitializeFunc)(int, int, const char*, int);
typedef int (*espeakSetVoiceByNameFunc)(const char*);
typedef const void* (*espeakGetCurrentVoiceFunc)(void);
typedef int (*espeakSetVoiceByPropertiesFunc)(const void*);
typedef int (*espeakSynchronizeFunc)(void);

void Help();
void Initialization();
void VariaveisDefault()



#ifdef _WIN64
#include <winsock2.h>
#pragma comment(lib, "ws2_32.lib") // Esta linha é necessária para linkar a biblioteca ws2_32.lib com o programa,
#endif

#ifdef _LINUX
#include<sys/socket.h>
#include<arpa/inet.h> //inet_addr
#include<unistd.h>    //write
//#include <espeak/speak_lib.h>
#include <espeak-ng/speak_lib.h>
#endif


void VariaveisDefault()
{
   strcpy(sTipoVoz, "mb/mb-br4");
}

//InicializaÃ§Ã£o de variaveis
void Initialization()
{
 //InicializaÃ§Ã£o de variaveis
 memset(sTipoVoz,'\0',sizeof(sTipoVoz));

 //Variaveis Default
 VariaveisDefault();


}

#ifdef _LINUX
int socket_desc, client_sock, c, read_size;
struct sockaddr_in server, client;
char client_message[2000];

#endif

#ifdef _LINUX
espeak_AUDIO_OUTPUT output;
#endif

#ifdef _WIN64
void Ler(char* frase) {

}
#endif

#ifdef _WIN32
void Ler_SAPI(char* frase) {
    // Inicializar a COM
    CoInitialize(NULL);

    ISpVoice* pVoice = NULL;

    // Criar uma instância da interface ISpVoice
    CoCreateInstance(&CLSID_SpVoice, NULL, CLSCTX_ALL, &IID_ISpVoice, (void**)&pVoice);

    // Converter a string para wide string (wchar_t*)
    int wstr_size = MultiByteToWideChar(CP_UTF8, 0, frase, -1, NULL, 0);
    wchar_t* wfrase = (wchar_t*)malloc(wstr_size * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, frase, -1, wfrase, wstr_size);

    // Converter o texto para fala
    pVoice->lpVtbl->Speak(pVoice, wfrase, 0, NULL);

    // Aguardar a conclusão da fala
    SPVOICESTATUS status;
    pVoice->lpVtbl->GetStatus(pVoice, &status, NULL);
    while (status.dwRunningState == SPRS_IS_SPEAKING) {
        Sleep(100);
        pVoice->lpVtbl->GetStatus(pVoice, &status, NULL);
    }

    // Liberar recursos
    pVoice->lpVtbl->Release(pVoice);
    CoUninitialize();
}

void Ler(char* frase) {
    char command[10000];
    // Constrói o comando para chamar a aplicação eSpeak com a frase
    snprintf(command, sizeof(command), "espeak.exe -v pt  \"%s\" ", frase);
    printf("Comando: %s\n", command);

    // Executa o comando
    int result = system(command);
    if (result != 0) {
        printf("Erro ao executar o comando espeak\n");
    }
}
#endif

#ifdef _LINUX
void Ler(char * frase) {
	int speakErr =0;
	if((speakErr=espeak_Synth(frase, strlen(frase), 0,0,0,espeakCHARS_AUTO,NULL,NULL))!= EE_OK){
		printf("Error on synth creation\n");
	}
	espeak_Synchronize();
}
#endif

#ifdef _WIN32
int Start_Voice() {

    return 0;
}
#endif

#ifdef _WIN64 
int Start_Voice()
{
    return 0;
}
#endif


#ifdef _LINUX
int Start_Voice()
{
	output = AUDIO_OUTPUT_PLAYBACK;
	int Buflength = 500;
	int Options=0;
	char *path=NULL;
	if(espeak_Initialize(output, Buflength, path, Options)<0){
		puts("could not initialize espeak\n");
		return -1;
	} else {
		puts("Ok\n");
	}

        //"mb/mb-br4"
	espeak_SetVoiceByName(sTipoVoz);
	espeak_SetParameter(espeakRATE, 120,0);
	espeak_SetParameter(espeakVOLUME, 100,0);
	espeak_VOICE *voice_spec=espeak_GetCurrentVoice();
	voice_spec->gender =2; //0=none 1=male, 2=female
	voice_spec->age=0; //0=not specified, or age in years
	espeak_SetVoiceByProperties(voice_spec);
	//espeak_SetSynthCallback(SynthCallback);
	espeak_Synchronize( );
	//t_espeak_callback *SynthCallback;
	return 0;	
}
#endif

#ifdef _WIN32
int controlesocket_windows32() {
    WSADATA wsa;
    SOCKET socket_desc, client_sock;
    struct sockaddr_in server, client;
    int c, read_size;
    char client_message[2000];

    // Inicializa o subsistema de sockets do Windows
    printf("\nInitialising Winsock...");
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
    {
        printf("Failed. Error Code : %d", WSAGetLastError());
        return 1;
    }
    printf("Initialised.\n");

    // Cria o socket
    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_desc == INVALID_SOCKET) {
        printf("Could not create socket : %d", WSAGetLastError());
        WSACleanup();
        return 1;
    }
    puts("Socket created");

    // Prepara a estrutura sockaddr_in
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons(PORTSRV);

    // Bind
    if (bind(socket_desc, (struct sockaddr*)&server, sizeof(server)) == SOCKET_ERROR) {
        printf("Bind failed with error code : %d", WSAGetLastError());
        closesocket(socket_desc);
        WSACleanup();
        return 1;
    }
    puts("Bind done");

    int flgAtivo = 1;
    while (flgAtivo == 1) {
        // Ouve por conexões
        listen(socket_desc, 3);

        // Aceita conexões entrantes
        puts("Waiting for incoming connections...");
        c = sizeof(struct sockaddr_in);

        client_sock = accept(socket_desc, (struct sockaddr*)&client, &c);
        if (client_sock == INVALID_SOCKET) {
            printf("accept failed with error code : %d", WSAGetLastError());
            closesocket(socket_desc);
            WSACleanup();
            return 1;
        }
        puts("Connection accepted");

        memset(client_message, '\0', sizeof(client_message));

        // Recebe mensagem do cliente
        while ((read_size = recv(client_sock, client_message, 2000, 0)) > 0) {
            // Processa a mensagem recebida
            printf("%s\n", client_message);
            //Ler(client_message); // Supondo que Ler seja uma função definida por você
            Ler_SAPI(client_message); // Supondo que Ler seja uma função definida por você
            memset(client_message, '\0', sizeof(client_message));
        }

        if (read_size == 0) {
            puts("Client disconnected");
            fflush(stdout);
        }
        else if (read_size == -1) {
            printf("recv failed with error code : %d", WSAGetLastError());
        }

        closesocket(client_sock);
    }

    closesocket(socket_desc);
    WSACleanup(); // Limpa o subsistema de sockets
    return 0;
}
#endif

#ifdef _WIN64
int controlesocket_windows64()
{
  return 0;
}
#endif



#ifdef _LINUX
int controlesocket_linux()
{
    //Create socket
    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_desc == -1)
    {
        printf("Could not create socket");
    }
    puts("Socket created");


    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons(PORTSRV);

    //Bind
    if (bind(socket_desc, (struct sockaddr*)&server, sizeof(server)) < 0)
    {
        //print the error message
        perror("bind failed. Error");
        return 1;
    }
    puts("bind done");
    int flgAtivo = 1;
    while (flgAtivo == 1)
    {
        //Listen
        listen(socket_desc, 3);

        //Accept and incoming connection
        puts("Waiting for incoming connections...");
        c = sizeof(struct sockaddr_in);
        //while(flgAtivo==1)

        //accept connection from an incoming client
        client_sock = accept(socket_desc, (struct sockaddr*)&client, (socklen_t*)&c);
        if (client_sock < 0)
        {
            perror("accept failed");
            return 1;
        }
        puts("Connection accepted");
        memset(client_message, '\0', sizeof(client_message));
        //Receive a message from client
        while ((read_size = recv(client_sock, client_message, 2000, 0)) > 0)
        {
            printf("%s\n", client_message);
            //Send the message back to client
            //write(client_sock , client_message , strlen(client_message));
            //printf(client_message);
            Ler(client_message);
            memset(client_message, '\0', sizeof(client_message));
        }

        if (read_size == 0)
        {
            puts("Client disconnected");
            fflush(stdout);
        }
        else if (read_size == -1)
        {
            perror("recv failed");
        }
    }
}
#endif


void Help()
{
     printf("Server Falar \n\n");
     printf("Develop by Marcelo Maurin Martins \n");
     printf("Options:  \n");
     printf(" -h Help \n");
     printf(" -p pitch [value]  \n");
     printf(" -v voice type [0-5]  \n");
     printf("  \n\n");

     exit(0);

}


#ifdef _LINUX
void setparametros(int argc, char *argv[]) {
    int opt;
    while ((opt = getopt(argc, argv, "hpv:")) != -1) {
        switch (opt) {
            case 'h':
                //printf("OpÃ§Ã£o -h selecionada\n");
                Help();

                break;
            case 'p':
                printf("OpÃ§Ã£o -p selecionada com o valor: %s\n", optarg);
                break;
            case 'v':
                printf("OpÃ§Ã£o -v selecionada com o valor: %s\n", optarg);
                break;

            default: /* '?' */
                fprintf(stderr, "Uso: %s [-v] [-h] [-c valor]\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }
}
#endif



int main(int argc , char *argv[])
{
#ifdef _LINUX
    // Chamar a funÃ§Ã£o setparametros
    setparametros(argc, argv);
#endif

    Start_Voice();
     
    #ifdef _WIN32
    controlesocket_windows32();
    #endif

    #ifdef _WIN64
    controlesocket_windows64();
    #endif

    #ifdef _LINUX
	controlesocket_linux();
    #endif

    return 0;
}

