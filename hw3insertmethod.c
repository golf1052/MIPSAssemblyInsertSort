// Insert sort
for(i = 1; i < length; i++) {
     char *value = a[i];
     for (j = i-1; j >= 0 && str_lt(value, a[j]); j--) {
         a[j+1] = a[j];
     }
     a[j+1] = value;
}

// Expanded insert sort for implementation
for (i = 1; i < length; i ++)
{
	char *value = a[i];
	for (j = i - 1; j >= 0; j--)
	{
		if (str_lt(value, a[j]))
		{
			a[j + 1] = a[j];
		}
		else
		{
			break;
		}
	}
	
	a[j + 1] = value;
}