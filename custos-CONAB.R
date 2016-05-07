################################################
### Montar base de dados de custos agrícolas ###
################################################
# Encoding = LATIN1

setwd("C:/Documentos/myID/R")
install.packages("xlsx")
library(xlsx)
library(stringr)

# Faz download do script da CONAB
download.file(url = "http://conab.gov.br/conteudos.php?a=1555&t=2", destfile = "scriptCONAB.php")

# Lê o script da CONAB em um objeto.
script <- read.table("scriptCONAB.php", fill = TRUE, stringsAsFactors = FALSE)

# Encontra os link para download no script
col_links <- grep(pattern = "uploads", x = script)
lin_links <- grep(pattern = "uploads", x = script[[col_links]])
links <- script[lin_links, col_links]
links <- gsub(pattern = "href=\\\"", replacement = "", x = links)
links <- gsub(pattern = "xls\\\"", replacement = "xls", x = links)
links

# Extrai o nome das tabelas
tabelas <- str_extract_all(string = links, pattern = "_[a-z]+[-]?[a-z]+[-]?_")
tabelas <- gsub(pattern = "_", replacement = "", x = tabelas)
tabelas <- paste0(tabelas, ".xls")

# Define função que l? todas as abas da tabela
le_abas <- function(tabela) {
  wb <- loadWorkbook(tabela)
  numAbas <- wb$getNumberOfSheets()
  resultado <- vector("list", length = numAbas)
  for (aba in 1:numAbas) {
    resultado[[aba]] <- read.xlsx(as.character(tabela), sheetIndex = aba,
                                  rowIndex = 1:60, colIndex = 1:4,
                                  stringsAsFactors = FALSE)
  }
  names(resultado) <- names(getSheets(wb))
  return(resultado)
}
# Fim da função

# Testando a função para ler os custos de milho
milho <- le_abas("Dados/milho_1997_a_2015.xls")
str(milho, max.level = 1)
names(milho[32])
copia <- milho
# Fim do teste

# Define função que elimina tabelas vazias da lista
elimina_NULL <- function(lista) {
  if (is.list(lista) == TRUE) {
    resultado <- numeric(1)
    for (i in 1:length(lista)) {
      if (is.null(lista[[i]]) == TRUE) resultado <- c(resultado, i)
    }
    return(lista[-resultado])
  }  
  else {warning("Argumento não é uma lista")}
}
# Fim da função

# Testa a função para limpar os custos de milho
copia <- elimina_NULL(copia)
str(copia[59:119])
# Fim do teste

################################
## ERRO NESTA PARTE DO C?DIGO ##
################################

# Define função  que atribui nome as variáveis
arruma_nomes <- function(tabela) {
  for (i in 1:length(tabela)) {
    names(tabela[[i]]) <- c("Descrição",
                            "R$ha",
                            "R$saca",
                            "Participação no custo(%)")
  }
  return(tabela)
}

# Fim da função

arruma_nomes(copia)
names(copia[[5]])
str(copia)
# Define função que tira linhas indesejadas
tira_titulos <- function(x) {
  titulos <- c(grep(pattern = "I -",
                    x = x[[1]]),
               grep(pattern = "V -", 
                    x = x[[1]]))
  resultado <- x [-(titulos), ]
  return(resultado)
}
# Fim da função

# Adiciona uma coluna com o nome da cultura em todos as tabelas
adic_cultura <- function(tabela, cultura) {
  return(lapply(tabela, cbind, cultura = as.character(cultura)))
}
