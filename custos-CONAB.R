################################################
### Montar base de dados de custos agrícolas ###
################################################

#setwd("C:/Documentos/myID/R")   - não funcionou para mim... buscar conhecer forma mais funcional entre OS (caminho relativo?)
install.packages("xlsx")
install.packages("stringr") # precisei adicionar - não veio instalado por padrão na instalação do OS (openSUSE 13.2)
library(xlsx)
library(stringr)

# Faz download do script da CONAB
download.file(url = "http://conab.gov.br/conteudos.php?a=1555&t=2",
              destfile = "scriptCONAB.html")

# Lê o script da CONAB em um objeto.
script <- read.table("scriptCONAB.html",
                     fill = TRUE,
                     stringsAsFactors = FALSE)

# Encontra os link para download no script
Sys.setlocale('LC_ALL','C') # sugerido como solução para mensagens de aviso do tipo "string de entrada 218 é inválida nesse locale"
col_links <- grep(pattern = "uploads",
                  x = script)
lin_links <- grep(pattern = "uploads",
                  x = script[[col_links]])
links <- script[lin_links, col_links]
links <- gsub(pattern = "href=\\\"",
              replacement = "", x = links)
links <- gsub(pattern = "xls\\\"",
              replacement = "xls", x = links)
rm(list = c("script", "col_links", "lin_links"))

# Extrai o nome das tabelas
nomes <- str_extract_all(string = links, 
                         pattern = "_[a-z]+[-]?[a-z]+[-]?_")
nomes <- gsub(pattern = "_",
              replacement = "",
              x = nomes)

# Faz download da serie histórica de custo de produção
dir.create("Dados")
setwd("Dados")
for (i in seq_along(nomes)) {
  download.file(url = links[i],
                destfile = paste0(nomes[i], ".xls"))
  cat("Download do arquivo número",i,"concluido")
}
setwd("../")

# Define função que lê todas as abas da tabela
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
milho <- le_abas("Dados/milho.xls")
str(milho, max.level = 1)
names(milho[32])
copia <- milho
# Fim do teste

# Pegar informações do cabeçalho
  # a) Cidade - UF
  # b) Safra
  # c) Produto
  # d) Nível de tecnologia

# Adicionar estas informações como novas colunas

# Eliminar cabeçalho e tirar títulos

# Arrumar dados (colunas que foram lidas erradas)

# Empilhar tabelas em uma única tabela
