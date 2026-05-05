// Italian Localization for Digital Vault Heritage v3.0
class AppLocalizations {
  const AppLocalizations();

  // App General
  static const String appName = 'Digital Vault Heritage';
  static const String appTagline = 'Proteggi il Tuo Patrimonio Digitale';
  static const String getStarted = 'Inizia';
  static const String skipForNow = 'Salta per Adesso';
  static const String continueText = 'Continua';
  static const String cancel = 'Annulla';
  static const String save = 'Salva';
  static const String delete = 'Elimina';
  static const String edit = 'Modifica';
  static const String add = 'Aggiungi';
  static const String remove = 'Rimuovi';
  static const String confirm = 'Conferma';
  static const String retry = 'Riprova';
  static const String loading = 'Caricamento...';
  static const String error = 'Errore';
  static const String success = 'Successo';
  static const String warning = 'Avviso';
  static const String info = 'Informazioni';

  // Authentication
  static const String welcomeToDigitalVault = 'Benvenuto in Digital Vault Heritage';
  static const String createYourPin = 'Crea il Tuo PIN';
  static const String enterYourPin = 'Inserisci il Tuo PIN';
  static const String confirmPin = 'Conferma PIN';
  static const String pinHint = 'Inserisci PIN di 4-8 cifre';
  static const String pinCreated = 'PIN Creato con Successo';
  static const String pinMismatch = 'I PIN non corrispondono';
  static const String pinTooShort = 'Il PIN deve avere almeno 4 cifre';
  static const String pinTooLong = 'Il PIN non può superare 8 cifre';
  static const String invalidPin = 'Formato PIN non valido';
  static const String pinLocked = 'Troppi tentativi falliti. Riprova più tardi.';
  static const String sessionExpired = 'Sessione Scaduta';
  static const String pleaseEnterPinAgain = 'Per favore inserisci di nuovo il tuo PIN';
  static const String unlock = 'Sblocca';
  static const String lock = 'Blocca';

  // Biometric Authentication
  static const String enableBiometricAuth = 'Abilita Autenticazione Biometrica';
  static const String useBiometrics = 'Usa Biometrica';
  static const String biometricNotAvailable = 'Autenticazione biometrica non disponibile';
  static const String biometricAuthFailed = 'Autenticazione biometrica fallita';
  static const String biometricSetupSuccess = 'Autenticazione biometrica abilitata';

  // Vault Management
  static const String yourDigitalVault = 'La Tua Cassaforte Digitale';
  static const String noDocumentsYet = 'Nessun documento ancora';
  static const String addDocument = 'Aggiungi Documento';
  static const String uploadDocument = 'Carica Documento';
  static const String documentName = 'Nome Documento';
  static const String selectFile = 'Seleziona File';
  static const String documentUploaded = 'Documento caricato con successo';
  static const String uploadFailed = 'Caricamento fallito';
  static const String networkError = 'Errore di Rete';
  static const String unableToUploadFile = 'Impossibile caricare il file. Controlla la tua connessione.';
  static const String fileSizeTooLarge = 'Dimensione file troppo grande';
  static const String unsupportedFileType = 'Tipo di file non supportato';

  // Document Categories
  static const String identity = 'Identità';
  static const String financial = 'Finanza';
  static const String legal = 'Legale';
  static const String personal = 'Personale';
  static const String medical = 'Medico';
  static const String other = 'Altro';

  // Document Details
  static const String documentDetails = 'Dettagli Documento';
  static const String fileName = 'Nome File';
  static const String fileSize = 'Dimensione File';
  static const String uploadedOn = 'Caricato Il';
  static const String lastModified = 'Ultima Modifica';
  static const String category = 'Categoria';
  static const String shareWithHeirs = 'Condividi con Eredi';
  static const String heirAccessLevel = 'Livello Accesso Erede';
  static const String noAccess = 'Nessun Accesso';
  static const String readOnly = 'Sola Lettura';
  static const String readWrite = 'Lettura Scrittura';
  static const String fullAccess = 'Accesso Completo';

  // Dead Man's Switch
  static const String deadMansSwitch = 'Dead Man\'s Switch';
  static const String activateDeadMansSwitch = 'Attiva Dead Man\'s Switch';
  static const String deadMansSwitchActive = 'Dead Man\'s Switch Attivo';
  static const String deadMansSwitchInactive = 'Dead Man\'s Switch Inattivo';
  static const String checkInInterval = 'Intervallo Check-in';
  static const String maxMissedCheckIns = 'Check-in Massimi Mancati';
  static const String gracePeriod = 'Periodo di Grazia';
  static const String hours = 'ore';
  static const String days = 'giorni';
  static const String weeks = 'settimane';
  static const String months = 'mesi';
  static const String years = 'anni';

  // Check-in System
  static const String performCheckIn = 'Esegui Check-in';
  static const String checkInSuccessful = 'Check-in eseguito con successo';
  static const String checkInFailed = 'Check-in fallito';
  static const String lastCheckIn = 'Ultimo Check-in';
  static const String nextCheckInDue = 'Prossimo Check-in Richiesto';
  static const String missedCheckIns = 'Check-in Mancati';
  static const String checkInChannels = 'Canali Check-in';
  static const String emailCheckIn = 'Check-in Email';
  static const String smsCheckIn = 'Check-in SMS';
  static const String pushCheckIn = 'Notifica Push';
  static const String inAppCheckIn = 'Check-in In-App';

  // Grace Period
  static const String gracePeriodActive = 'Periodo di Grazia Attivo';
  static const String timeRemaining = 'Tempo rimanente';
  static const String cancelGracePeriod = 'Annulla Periodo di Grazia';
  static const String heirsWillBeNotified = 'Gli eredi saranno notificati se non verrà intrapresa alcuna azione';
  static const String gracePeriodCancelled = 'Periodo di grazia annullato con successo';
  static const String emergencyProtocol = 'Protocollo di Emergenza';

  // Heir Management
  static const String heirs = 'Eredi';
  static const String addHeir = 'Aggiungi Erede';
  static const String heirConfiguration = 'Configurazione Erede';
  static const String heirName = 'Nome Erede';
  static const String heirEmail = 'Email Erede';
  static const String heirPhone = 'Telefono Erede';
  static const String heirRelationship = 'Relazione';
  static const String saveHeir = 'Salva Erede';
  static const String heirAdded = 'Erede aggiunto con successo';
  static const String heirUpdated = 'Erede aggiornato con successo';
  static const String heirDeleted = 'Erede eliminato con successo';
  static const String noHeirsConfigured = 'Nessun erede configurato';
  static const String heirsConfigured = 'eredi configurati';

  // Heir Relationships
  static const String spouse = 'Coniuge / Partner';
  static const String child = 'Figlio / Figlia';
  static const String parent = 'Genitore';
  static const String sibling = 'Fratello / Sorella';
  static const String friend = 'Amico / Amica';
  static const String lawyer = 'Avvocato / Notaio';
  static const String otherRelationship = 'Altro';

  // Conditional Inheritance
  static const String inheritanceRules = 'Regole di Eredità';
  static const String addInheritanceRule = 'Aggiungi Regola di Eredità';
  static const String ruleName = 'Nome Regola';
  static const String ruleDescription = 'Descrizione Regola';
  static const String conditionType = 'Tipo Condizione';
  static const String timeBased = 'Basata sul Tempo';
  static const String eventBased = 'Basata su Evento';
  static const String locationBased = 'Basata su Posizione';
  static const String approvalBased = 'Basata su Approvazione';
  static const String customCondition = 'Condizione Personalizzata';
  static const String allowedHeirs = 'Eredi Consentiti';
  static const String allowedFolders = 'Cartelle Consentite';
  static const String allowedDocumentTypes = 'Tipi Documento Consentiti';
  static const String saveRule = 'Salva Regola';
  static const String ruleCreated = 'Regola creata con successo';
  static const String ruleUpdated = 'Regola aggiornata con successo';
  static const String ruleDeleted = 'Regola eliminata con successo';

  // Subscription Management
  static const String subscription = 'Abbonamento';
  static const String chooseYourPlan = 'Scegli il Tuo Piano';
  static const String currentPlan = 'Piano Attuale';
  static const String freePlan = 'Piano Gratuito';
  static const String premiumPlan = 'Piano Premium';
  static const String lifetimePlan = 'Piano Vitalizio';
  static const String upgrade = 'Aggiorna';
  static const String upgradeToPremium = 'Aggiorna a Premium';
  static const String billingCycle = 'Ciclo di Fatturazione';
  static const String monthly = 'Mensile';
  static const String yearly = 'Annuale';
  static const String lifetime = 'Vitalizio';
  static const String paymentInformation = 'Informazioni di Pagamento';
  static const String cardNumber = 'Numero Carta';
  static const String expiryDate = 'Data Scadenza';
  static const String cvv = 'CVV';
  static const String completePayment = 'Completa Pagamento';
  static const String paymentSuccessful = 'Pagamento completato con successo';
  static const String paymentFailed = 'Pagamento fallito';
  static const String premiumPlanActive = 'Piano Premium Attivo';
  static const String subscriptionCancelled = 'Abbonamento annullato con successo';

  // Plan Features
  static const String features = 'Funzionalità';
  static const String documents = 'Documenti';
  static const String maxDocuments = 'Documenti Massimi';
  static const String unlimited = 'Illimitati';
  static const String maxHeirs = 'Eredi Massimi';
  static const String deadMansSwitchFeature = 'Dead Man\'s Switch';
  static const String conditionalInheritance = 'Eredità Condizionale';
  static const String multiChannelCheckIn = 'Check-in Multi-canale';
  static const String userReports = 'Report Utente';
  static const String advancedSecurity = 'Sicurezza Avanzata';

  // User Reporting
  static const String reportSettings = 'Impostazioni Report';
  static const String reportFrequency = 'Frequenza Report';
  static const String weekly = 'Settimanale';
  static const String quarterly = 'Trimestrale';
  static const String semiAnnually = 'Semestrale';
  static const String annually = 'Annuale';
  static const String includeCharts = 'Includi Grafici';
  static const String includeDetailedLogs = 'Includi Log Dettagliati';
  static const String saveSettings = 'Salva Impostazioni';
  static const String generateReport = 'Genera Report';
  static const String sendReport = 'Invia Report';
  static const String vaultStatusReport = 'Report Stato Cassaforte';
  static const String generatedOn = 'Generato il';
  static const String totalDocuments = 'Documenti Totali';
  static const String totalSize = 'Dimensione Totale';
  static const String sharedDocuments = 'Documenti Condivisi';
  static const String securitySummary = 'Riepilogo Sicurezza';
  static const String heirStatus = 'Stato Eredi';
  static const String subscriptionStatus = 'Stato Abbonamento';

  // Security Features
  static const String security = 'Sicurezza';
  static const String securitySettings = 'Impostazioni di Sicurezza';
  static const String changePin = 'Cambia PIN';
  static const String currentPin = 'PIN Attuale';
  static const String newPin = 'Nuovo PIN';
  static const String confirmNewPin = 'Conferma Nuovo PIN';
  static const String pinChanged = 'PIN cambiato con successo';
  static const String enableTwoFactor = 'Abilita Autenticazione a Due Fattori';
  static const String twoFactorEnabled = 'Autenticazione a due fattori abilitata';
  static const String twoFactorDisabled = 'Autenticazione a due fattori disabilitata';

  // Settings
  static const String settings = 'Impostazioni';
  static const String generalSettings = 'Generali';
  static const String language = 'Lingua';
  static const String theme = 'Tema';
  static const String darkTheme = 'Tema Scuro';
  static const String lightTheme = 'Tema Chiaro';
  static const String systemTheme = 'Tema di Sistema';
  static const String notifications = 'Notifiche';
  static const String emailNotifications = 'Notifiche Email';
  static const String pushNotifications = 'Notifiche Push';
  static const String smsNotifications = 'Notifiche SMS';
  static const String about = 'Informazioni';
  static const String version = 'Versione';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Termini di Servizio';
  static const String contactSupport = 'Contatta Supporto';

  // Error Messages
  static const String somethingWentWrong = 'Qualcosa è andato storto';
  static const String pleaseTryAgain = 'Per favore riprova';
  static const String noInternetConnection = 'Nessuna connessione internet';
  static const String serverError = 'Errore del server';
  static const String unauthorized = 'Non autorizzato';
  static const String forbidden = 'Accesso negato';
  static const String notFound = 'Non trovato';
  static const String timeout = 'Timeout richiesta';
  static const String invalidCredentials = 'Credenziali non valide';
  static const String accountLocked = 'Account bloccato';
  static const String maintenanceMode = 'Sistema in manutenzione';

  // Success Messages
  static const String operationSuccessful = 'Operazione completata con successo';
  static const String dataSaved = 'Dati salvati con successo';
  static const String changesApplied = 'Modifiche applicate con successo';
  static const String configurationUpdated = 'Configurazione aggiornata con successo';
  static const String vaultIsReady = 'La Tua Cassaforte è Pronta';
  static const String welcomeBack = 'Bentornato';

  // Legal and Compliance
  static const String legalPolicy = 'Policy Legale';
  static const String termsAndConditions = 'Termini e Condizioni';
  static const String dataProtection = 'Protezione Dati';
  static const String gdprCompliance = 'Conformità GDPR';
  static const String ccpaCompliance = 'Conformità CCPA';
  static const String zeroKnowledgeDefense = 'Difesa Zero-Knowledge';
  static const String notLegalAdvice = 'Non è un Consiglio Legale';

  // Recovery
  static const String recovery = 'Recupero';
  static const String recoveryKey = 'Chiave di Recupero';
  static const String generateRecoveryKey = 'Genera Chiave di Recupero';
  static const String saveRecoveryKey = 'Salva Chiave di Recupero in Modo Sicuro';
  static const String recoveryKeyGenerated = 'Chiave di recupero generata';
  static const String recoveryKeyWarning = 'Salva questa chiave in un posto sicuro. Ti servirà per recuperare la tua cassaforte.';
  static const String recoverVault = 'Recupera Cassaforte';
  static const String enterRecoveryKey = 'Inserisci Chiave di Recupero';
  static const String invalidRecoveryKey = 'Chiave di recupero non valida';
  static const String vaultRecovered = 'Cassaforte recuperata con successo';

  // Backup and Sync
  static const String backup = 'Backup';
  static const String createBackup = 'Crea Backup';
  static const String restoreBackup = 'Ripristina Backup';
  static const String backupCreated = 'Backup creato con successo';
  static const String backupRestored = 'Backup ripristinato con successo';
  static const String lastBackup = 'Ultimo Backup';
  static const String automaticBackup = 'Backup Automatico';
  static const String backupFrequency = 'Frequenza Backup';

  // Statistics and Analytics
  static const String statistics = 'Statistiche';
  static const String vaultStatistics = 'Statistiche Cassaforte';
  static const String totalVaultSize = 'Dimensione Totale Cassaforte';
  static const String documentsByCategory = 'Documenti per Categoria';
  static const String heirActivity = 'Attività Eredi';
  static const String securityEvents = 'Eventi di Sicurezza';
  static const String lastLogin = 'Ultimo Accesso';
  static const String failedLogins = 'Accessi Falliti';

  // Help and Support
  static const String help = 'Aiuto';
  static const String faq = 'Domande Frequenti';
  static const String tutorial = 'Tutorial';
  static const String contactUs = 'Contattaci';
  static const String feedback = 'Feedback';
  static const String reportIssue = 'Segnala Problema';

  // Placeholders for Legal Compliance
  static const String ownerDetails = '[INSERISCI_DETTAGLIO_PROPRIETARIO]';
  static const String companyName = '[INSERISCI_NOME_COMPANY]';
  static const String supportEmail = '[INSERISCI_EMAIL_SUPPORTO]';
  static const String legalAddress = '[INSERISCI_INDIRIZZO_LEGALE]';
  static const String privacyContact = '[INSERISCI_CONTATTO_PRIVACY]';
}
