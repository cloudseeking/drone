locals {
  tags = {
    # Tags obrigatórias por Azure Policy
    CC        = "1020800"             # Centro de Custo
    CCOWNER   = "JOCILENE SANTOS"     # Proprietário do Centro de Custo
    BU        = "FUNDOS"         # Unidade de Negócio (valores permitidos: BANCOS E CAMBIO, PREVIDENCIA, CONSORCIOS, FUNDOS, DIGITAL, ADMINISTRATIVO FINANCEIRO, SERVICOS, COMERCIAL E MARKETING, DIRETORIA DE INOVACAO, PIX/PSTI)
    AMBIENTE  = "QA"                  # Ambiente (valores permitidos: PRD, HML, DEV, QA, WVD, POC, DEVOPS, SHELF)
    PROJECT   = "SINQIA CONTROLADORIA"      # Nome do projeto
    CRIADOEM  = timeadd(timestamp(), "-3h")
    CRIADOPOR = "modernizacao@sinqia.com.br"
  }
}
