# Passo a Passo do Projeto
# Passo 1: Entrar no sistema da empresa
# dlp.hashtagtreinamentos.com/python/intensivao/login
# pip install pyautogui
import pyautogui
import time

pyautogui.PAUSE = 1

# pyautogui.click -- clica em algum lugar da tela
# pyautogui.write -- escrever um texto
# pyautogui.press -- pressionar uma tecla do teclado
# abrir o navegador (edge)
pyautogui.press("win")
pyautogui.write("edge")
pyautogui.press("enter")

# entrar no site
link = "https://dlp.hashtagtreinamentos.com/python/intensivao/login"

# dar uma pausa um pouco maior
time.sleep(2)

pyautogui.write(link)
pyautogui.press("enter")

# Passo 2: Fazer login
pyautogui.click(x=833, y=492)
pyautogui.write("python@gmail.com")

# escrever a senha
pyautogui.press("tab")
pyautogui.write("teste")

# clicar no botão de logar
pyautogui.press("tab")
pyautogui.press("enter")

# Passo 3: Importar a base de dados
import pandas

tabela = pandas.read_csv("produtos.csv")

# Passo 4: Cadastrar 1 produto

pyautogui.click(x=784, y=352)

pyautogui.write("codigo")
pyautogui.press("tab")
pyautogui.write("marca")
pyautogui.press("tab")
pyautogui.write("tipo")
pyautogui.press("tab")
pyautogui.write("categoria")
pyautogui.press("tab")
pyautogui.write("preco_unitario")
pyautogui.press("tab")
pyautogui.write("custo")
pyautogui.press("tab")
pyautogui.write("obs")
pyautogui.press("tab")
pyautogui.press("enter")
pyautogui.scroll(5000)

# Passo 5: Repetir o processo de cadastro até acabar
for linha in tabela.index:
# se fosse para coluna seria for coluna in tabela.columns

    pyautogui.click(x=784, y=352)
    codigo = tabela.loc[linha, "codigo"]
    pyautogui.write("codigo")
    pyautogui.press("tab")

    marca = tabela.loc[linha, "marca"]
    pyautogui.write("marca")
    pyautogui.press("tab")

    pyautogui.write(tabela.loc[linha, "tipo"])
    pyautogui.press("tab")

    # str() string -> texto
    # str(1) -> 1 -> "1"

    pyautogui.write(str(tabela.loc[linha, "categoria"]))
    pyautogui.press("tab")


    pyautogui.write(str(tabela.loc[linha, "preco_unitario"]))
    pyautogui.press("tab")

    pyautogui.write(str(tabela.loc[linha, "custo"]))
    pyautogui.press("tab")
    
    obs = tabela.loc[linha, "obs"]
    if not  pandas.isna(obs): # verifica se está vazio
        pyautogui.write(obs)
    pyautogui.press("tab")
    pyautogui.press("enter")
    pyautogui.scroll(5000)

