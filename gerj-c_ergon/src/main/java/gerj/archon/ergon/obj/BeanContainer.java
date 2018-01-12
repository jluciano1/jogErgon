package gerj.archon.ergon.obj;

import java.io.Serializable;

import org.springframework.beans.factory.NoSuchBeanDefinitionException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.transaction.TransactionStatus;

import techne.IBeanContainer;

public class BeanContainer implements IBeanContainer {
	private ApplicationContext applicationContext;

	public BeanContainer() {
		this(new ClassPathXmlApplicationContext("gerj.archon.ergon.bean.xml"));
	}

	public BeanContainer(ApplicationContext applicationContext) {
		this.applicationContext = applicationContext;
	}

	@Override
	public void openCurrentSession() {
	}

	@Override
	public void closeCurrentSession() {
	}

	@Override
	public Object getBean(String beanName) throws BeanNotFoundException {
		try {
			return this.applicationContext.getBean(beanName);
		} catch (NoSuchBeanDefinitionException e) {
			throw new BeanNotFoundException(e);
		}
	}

	@Override
	public <T> T getBean(Class<T> beanType) throws BeanNotFoundException {
		try {
		  return this.applicationContext.getBean( beanType );
		}
		catch(NoSuchBeanDefinitionException e) {
		  throw new BeanNotFoundException(e);
		}
	}

	@Override
	public Object getEntity(Class<?> classe, Serializable id) {
		throw new UnsupportedOperationException();
	}

	@Override
	public TransactionStatus beginTransaction() {
		/**
		 * A exception UnsupportedOperationException() foi comentada para poder executar rotinas Java diretamente do
		 * controller fileDownload. 
		 * Essa exception era usada, para verificar exceções causadas no banco de dados por rotinas PL/SQL e permitir ao cronos
		 * dar rollback nas alterações. Mas não tem nenhum benefício prático, uma vez que tratamos commit e rollback nas próprias 
		 * rotinas PL/SQL.
		 */
		//throw new UnsupportedOperationException();
		return null;
	}

	@Override
	public void commitOrRollback(TransactionStatus status) {
	}
}
