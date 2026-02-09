import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure
#%matplotlib inline
matplotlib.rcParams['figure.figsize'] = (12, 8)
##Display settings
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)

#read in the data
Movie_df=pd.read_csv("movies.csv")
print(Movie_df.head(10))
# let's see if there is any missing data
for column in Movie_df.columns:
    perc_missing=np.mean(Movie_df[column].isnull())
    #print('{}-{}%'.format(column, perc_missing))
#Change data
#print(Movie_df.dtypes)
Movie_df['budget'] = Movie_df['budget'].fillna(0).astype('int64')
Movie_df['budget']=Movie_df['budget'].astype('int64')
Movie_df['gross'] = Movie_df['gross'].fillna(0).astype('int64')
Movie_df['gross'] = Movie_df['gross'].astype('int64')

#print(Movie_df.dtypes)
#creat correct year column
Movie_df['yearcorect']=Movie_df['released'].astype('str').str[:4]
Movie_df=Movie_df.sort_values('gross', ascending=False, inplace=False)
# drop any duplicate
Movie_df['company']=Movie_df['company'].drop_duplicates().sort_values(ascending=False)
#print(Movie_df['company'])


#Budget might have high corrolation
#Company might have hight corrolation

#let's build a scatter plot with Budget vs Gross

plt.scatter(x=Movie_df['budget'],y=Movie_df['gross'])
plt.title('Budget vs Gross Earning')
plt.xlabel('gross earning')
plt.ylabel("budget for film")
plt.show()
print(Movie_df.head(10))
# let's do a reegression plot
sns.regplot(x='budget',y='gross',data=Movie_df, scatter_kws={'color':'red'}, line_kws={'color':'blue'})
plt.show()

# #let's start looking at corrolation
# numeric_df = Movie_df.select_dtypes(include='number')
# corr_matrix = numeric_df.corr(method="pearson") #peasrson corrolation, #kendall, Spearman
# print(corr_matrix)
# #high corrolation between budget and gross
# sns.heatmap(corr_matrix, annot=True)
# plt.title('Corrolation matrix for numeric features')
# plt.xlabel('Movie features')
# plt.ylabel("Movie features")
#plt.show()

#for non-numeric!
Movie_df_numerized=Movie_df

for col_name in Movie_df_numerized.columns:
    if(Movie_df_numerized[col_name].dtypes=='object'):
        Movie_df_numerized[col_name]=Movie_df_numerized[col_name].astype('category')
        Movie_df_numerized[col_name]=Movie_df_numerized[col_name].cat.codes


print(Movie_df_numerized.head(10))

non_numeric_df = Movie_df_numerized.select_dtypes(include='number')
corr_matrix_nonnum = non_numeric_df.corr(method="pearson") #peasrson corrolation, #kendall, Spearman
print(corr_matrix_nonnum)
#high corrolation between budget and gross
sns.heatmap(corr_matrix_nonnum, annot=True)
plt.title('Corrolation matrix for non-numeric features')
plt.xlabel('Movie features')
plt.ylabel("Movie features")

plt.show()
sorted_pairs=corr_matrix_nonnum.unstack().sort_values()
high_corr=sorted_pairs[sorted_pairs>0.5]
print(high_corr)

#votes and budget have the highest corrolation to gross earnings

#Company has low corrolation to gross or budget