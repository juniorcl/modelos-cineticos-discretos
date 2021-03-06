module globalSSR

	!este programa foi feito por base do modelo de exemplo do cap. 4 do livro barabasi
	!========================================================================================================
	integer(4)::vez		!vezes que o programa vai rodar. e o número de amos	
	integer(4)::L
	integer(4)::mol	!O número de moléculas que serão depositadas, as camadas serão mol/L
	integer(4),allocatable::S(:),VE(:),VD(:),RE(:)
	real(8),allocatable::WA(:),W(:)
	integer(4)::a,n,k,i,am,ca,p,erro,i2,deltah1,deltah2
	real(8)::b,h,z
	real(8),parameter::m=1.3
	!---------------------------- número aleatório -------------------------------------------------------------! 
	integer, parameter ::AMAG=843314861,BMAG=453816693,im=1073741824,a1=65539
	real*8, parameter::r_1=1.0/(4.0*im)
	integer ::iseed,jseed,rcont
	!-----------------------------------------------------------------------------------------------------------!
	!========================================================================================================

	contains
	subroutine arquivos !!arquivos que aparecerão

		iseed=88925613; jseed=83991
		
		if(L==1408) then					
			open(1,file='perfilSSRL=1408mol=200000Lamo=10000.dat')
			open(2,file='wSSRL=1408mol=200000Lamo=10000.dat')
			open(3,file='PR_SSRL=1408mol=200000Lamo=10000.dat')
		else if(L==1536) then
			open(1,file='perfilSSRL=1536mol=200000Lamo=10000.dat')
			open(2,file='wSSRL=1536mol=200000Lamo=10000.dat')
			open(3,file='PR_SSRL=1536mol=200000Lamo=10000.dat')
		else if(L==1664) then
			open(1,file='perfilSSRL=1664mol=200000Lamo=10000.dat')
			open(2,file='wSSRL=1664mol=200000Lamo=10000.dat')
			open(3,file='PR_SSRL=1664mol=200000Lamo=10000.dat')
		else if(L==1792) then
			open(1,file='perfilSSRL=1792mol=200000Lamo=10000.dat')
			open(2,file='wSSRL=1792mol=200000Lamo=10000.dat')
			open(3,file='PR_SSRL=1792mol=200000Lamo=10000.dat')
		else if(L==1928) then
			open(1,file='perfilSSRL=1928mol=200000Lamo=10000.dat')
			open(2,file='wSSRL=1928mol=200000Lamo=10000.dat')
			open(3,file='PR_SSRL=1928mol=200000Lamo=10000.dat')
		end if

	end subroutine
!================================================================================================!
	subroutine reg_var !!deixa o substrato circular

		do i=2, L
			VE(i)=i-1; VD(i)=i+1
		end do
		VD(L)=1; VE(1)=L; VD(1)=2

	end subroutine
!================================================================================================!
	subroutine calc_rug !!cáculo da rugosidade

		if(mod(n,L)==0) then !se o resto for 0 ele caracteriza a rugosidade
                	ca=ca+1
	                !=============================================================================================!
                    	!				cálculo da rugosidade de cada camada			      !
                    	!=============================================================================================!	       
			h=0; h=sum(S)/L	!média da altura da soma dos vetores
		        do i=1, L
				WA(i)=((S(i)-h)**2)	!primeira parte da esquação de rugosidade	
		        end do
			W(ca)=((sum(WA))/L)+W(ca) !aqui está contido a rugosidade de cada amostra com suas camadas
	                !==============================================================================================!
		end if

	end subroutine
!================================================================================================!	
	subroutine dados !!armazenamento dos dados
		do n=1, L
			write(1,*) n,S(n)
		end do		
			
		k=1
       		do n=1, mol/L   

			write(3,*) n, RE(n) !partículas rejeitadas
                	
			if(n==k) then
	        		write(2,*) n, W(n)
                	k=int(k*m)+1
                	end if
		end do
	end subroutine
!================================================================================================!
	subroutine depo		!!aqui ocorre as deposições ## cara aqui é o coração do programa ###

		deltah1=(S(a)-S(VD(a)))**2
		deltah2=(S(a)-S(VE(a)))**2

		if(deltah1<=1).and.(deltah2<=1) then

			S(a)=S(a)+1
			n=n+1

		else

			RE(ca)=RE(ca)+1

		end if

	end subroutine
!================================================================================================!
	subroutine troca_var	!!aqui haverá a troca de varáveis
		 
		if(L/=0) then	!!só entra aq quando já tiver algum valor em L
			
			deallocate(S,WA,W,VE,VD,RE,STAT=erro)
		
		end if			
			
		L=128*i2
		mol=200000*L
		allocate(S(1:L),WA(1:L),W(1:mol/L),VE(1:L),VD(1:L),RE(1:mol/L))
		
	end subroutine
!================================================================================================!
	subroutine programa !!programa a parte para a rugosidade
		
		vez=10000	!!número máximo de camadas
		
		do i2=11, 15 !!este do auxilia na troca de L

			call troca_var	!!aqui haverá a troca do !!

			call arquivos !!configura os melhores arquivos
		
			call reg_var  !!deixa o substrato circular

			do am=1, vez		

                		WA=0; S=0; ca=0

				do while(n<=mol)	!ficará tentando depositar todas 

					if (rcont.ge.1e7) then
    	 					rcont=0
    	 					iseed=a1*jseed
    	 					jseed=iseed
 					end if

					iseed=(AMAG*iseed)+BMAG; rcont=rcont+1; z=r_1*iseed+0.5d0
					a=int(z*L)+1

					call depo	!!regra da deposição

                	       		call calc_rug                    
			
				end do
		
			end do

			!=============================================!          
    			!         médias das partículas rejeitadas    !       
			!=============================================!
			do ca=1, mol/L !média das partículas rejeitadas

				RE(ca)=RE(ca)/vez

			end do
			!============================================!

			!=============================================!          
    			!		cálculo final da camadas      !       
			!=============================================!	
			do ca=1, mol/L 
        			W(ca)=sqrt(W(ca))
			end do
   			!=============================================!

			call dados !!coleta dos dados
 
		end do		 
	
	end subroutine
!=================================================================================================!		
end module globalSSR

program SSR
	use globalSSR
	call programa	!!cálculo da rugosidade
end program SSR
